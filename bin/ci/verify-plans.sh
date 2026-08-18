#!/bin/bash

set -eou pipefail

plan="$(basename "${1}")"
test_plan="$(basename "${2}")"
chef_policy_name="$(basename "${3}")"
HAB_ORIGIN=ci
export HAB_ORIGIN
export HAB_BLDR_CHANNEL="${HAB_BLDR_CHANNEL:-base-2025}"

# Fetch HAB_AUTH_TOKEN from AWS SSM if not already provided.
# The expeditor Docker executor does not forward host env vars automatically —
# only vars listed in the pipeline YAML env: section are injected into Docker.
if [[ -z "${HAB_AUTH_TOKEN:-}" ]]; then
  echo "--- :key: Fetching HAB_AUTH_TOKEN from AWS SSM"
  HAB_AUTH_TOKEN=$(aws ssm get-parameter \
    --name 'habitat-prod-auth-token' \
    --with-decryption \
    --query Parameter.Value \
    --output text \
    --region "${AWS_REGION:-us-west-2}" 2>/dev/null) || HAB_AUTH_TOKEN=""
fi
export HAB_AUTH_TOKEN
# Pass token and channel into Habitat studios via HAB_STUDIO_SECRET_ mechanism.
# The `build` alias inside a studio calls hab-plan-build and does NOT accept
# --refresh-channel; instead it reads HAB_BLDR_CHANNEL from the studio env.
export HAB_STUDIO_SECRET_HAB_AUTH_TOKEN="${HAB_AUTH_TOKEN}"
export HAB_STUDIO_SECRET_HAB_BLDR_CHANNEL="${HAB_BLDR_CHANNEL}"
# Git 2.35.2+ refuses to operate in directories owned by a different UID.
# Inside the Hab studio /src is mounted and owned by the host user, causing
# "dubious ownership" errors when chef-cli calls git to resolve Policyfiles.
export HAB_STUDIO_SECRET_GIT_CONFIG_COUNT=1
export HAB_STUDIO_SECRET_GIT_CONFIG_KEY_0=safe.directory
export HAB_STUDIO_SECRET_GIT_CONFIG_VALUE_0='*'

echo "--- :habicat: Installing Habitat 2.x"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
"${SCRIPT_DIR}/install-hab.sh" x86_64-linux

echo "--- :key: Generating fake origin key"
# This is intended to be run in the context of public CI where
# we won't have access to any valid signing keys.
hab origin key generate "${HAB_ORIGIN}"

echo "--- :construction: Starting build for ${plan}"
# We'll build from the root of the project's git repo. To do that,
# we'll need to ensure git is installed to determine the
# project root directory.
if type git 2>/dev/null; then
  echo "--- :thumbsup: git's installed"
else
  echo "--- :hammer_and_wrench: installing git"
  hab pkg install core/git --binlink
fi
project_root="$(git rev-parse --show-toplevel)"

# We want to ensure that we build the scaffolding package from the
# project root. When changing directories in scripts, doing so in
# a subshell () ensures that the script continues from the initial
# runtime directory regardless of the actions within.
( cd "$project_root" || exit 1

  echo "--- :construction: :linux: Building ${plan}"
  env DO_CHECK=true hab pkg build "${plan}" --refresh-channel "${HAB_BLDR_CHANNEL}"
)

source $project_root/results/last_build.env # scaffolding last_build.env
SCAFFOLDING_PKG_RELEASE=${pkg_release}
SCAFFOLDING_PKG_ARTIFACT=${pkg_artifact}

(cd "$project_root" || exit 1
  echo "--- :construction: :linux: Building ci/cacerts plan"
  hab studio -q -r "/hab/studios/ci-cacerts-${SCAFFOLDING_PKG_RELEASE}" run "build ${plan}/tests/cacerts"
  source results/last_build.env # cacerts last_build.env
  CACERTS_PKG_ARTIFACT="${pkg_artifact}"

  echo "--- :construction: :linux: Building ${test_plan} user plan for ${plan}"
  hab studio -q -r "/hab/studios/${test_plan}-${SCAFFOLDING_PKG_RELEASE}" run "hab pkg install results/${SCAFFOLDING_PKG_ARTIFACT} && hab pkg install results/${CACERTS_PKG_ARTIFACT} && build ${plan}/tests/${test_plan}"
  source results/last_build.env # user last_build.env
  TEST_PKG_RELEASE="${pkg_release}"
  TEST_PKG_ARTIFACT="${pkg_artifact}"
  TEST_PKG_IDENT="${pkg_ident}"

  echo "--- :mag: Testing ${pkg_ident}"
  if [ ! -f "${plan}/tests/${test_plan}/tests/test.sh" ]; then
    buildkite-agent annotate --style 'warning' ":warning: :linux: ${test_plan} has no tests to run."
    # TODO: When basic tests are created, change this to exit 1
    exit 0
  fi

  hab studio -q -r "/hab/studios/${test_plan}-${TEST_PKG_RELEASE}" run "export CHEF_POLICYFILE=${chef_policy_name} && hab pkg install results/${TEST_PKG_ARTIFACT} && ./${plan}/tests/${test_plan}/tests/test.sh ${TEST_PKG_IDENT}"
)

