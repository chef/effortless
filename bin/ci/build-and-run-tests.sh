#!/bin/bash

set -eou pipefail

plan="$(basename "${1}")"
HAB_ORIGIN=ci
export HAB_ORIGIN

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
  env DO_CHECK=true hab pkg build "${plan}"
)

source $project_root/results/last_build.env # scaffolding last_build.env
SCAFFOLDING_PKG_RELEASE=${pkg_release}
SCAFFOLDING_PKG_ARTIFACT=${pkg_artifact}

(cd "$project_root" || exit 1
  echo "--- :construction: :linux: Building default user plan for ${plan}"
  hab studio -q -r "/hab/studios/default-${SCAFFOLDING_PKG_RELEASE}" run "hab pkg install results/${SCAFFOLDING_PKG_ARTIFACT} && build ${plan}/tests/user-linux-default"
  source results/last_build.env # user last_build.env
  DEFAULT_PKG_RELEASE="${pkg_release}"
  DEFAULT_PKG_ARTIFACT="${pkg_artifact}"
  DEFAULT_PKG_IDENT="${pkg_ident}"

  echo "--- :mag: Testing ${pkg_ident}"
  if [ ! -f "${plan}/tests/test-default.sh" ]; then
    buildkite-agent annotate --style 'warning' ":warning: :linux: ${plan} has no Linux tests to run."
    # TODO: When basic tests are created, change this to exit 1
    exit 0
  fi

  hab studio -q -r "/hab/studios/default-${DEFAULT_PKG_RELEASE}" run "hab pkg install results/${DEFAULT_PKG_ARTIFACT} && ./${plan}/tests/test-default.sh ${DEFAULT_PKG_IDENT}"
)

set -e

(cd "$project_root" || exit 1
  # Need to rename the studio because studios cannot be re-entered due to umount issues.
  # Ref: https://github.com/habitat-sh/habitat/issues/6577
  echo "--- :construction: :linux: Building ci/cacerts plan"
  hab studio -q -r "/hab/studios/ci-cacerts-${SCAFFOLDING_PKG_RELEASE}" run "build ${plan}/tests/cacerts"
  source results/last_build.env # cacerts last_build.env
  CACERTS_PKG_ARTIFACT="${pkg_artifact}"

  echo "--- :construction: :linux: Building api user plan for ${plan}"
  hab studio -q -r "/hab/studios/api-${SCAFFOLDING_PKG_RELEASE}" run "hab pkg install results/${SCAFFOLDING_PKG_ARTIFACT} && hab pkg install results/${CACERTS_PKG_ARTIFACT} && build ${plan}/tests/user-linux"
  source results/last_build.env # user last_build.env
  API_PKG_RELEASE="${pkg_release}"
  API_PKG_ARTIFACT="${pkg_artifact}"
  API_PKG_IDENT="${pkg_ident}"

  echo "--- :mag: Testing ${pkg_ident}"
  if [ ! -f "${plan}/tests/test.sh" ]; then
    buildkite-agent annotate --style 'warning' ":warning: :linux: ${plan} has no Linux tests to run."
    # TODO: When basic tests are created, change this to exit 1
    exit 0
  fi

  hab studio -q -r "/hab/studios/api-${API_PKG_RELEASE}" run "hab pkg install results/${API_PKG_ARTIFACT} && ./${plan}/tests/test.sh ${API_PKG_IDENT}"

  echo "--- :construction: :linux: Building include policy with double quotes user plan"
  hab studio -q -r "/hab/studios/nested-double-${SCAFFOLDING_PKG_RELEASE}" run "export CHEF_POLICYFILE=double && hab pkg install results/${SCAFFOLDING_PKG_ARTIFACT} && build ${plan}/tests/user-linux-include-policy"

  echo "--- :construction: :linux: Building include policy with single quotes user plan"
  hab studio -q -r "/hab/studios/nested-single-${SCAFFOLDING_PKG_RELEASE}" run "export CHEF_POLICYFILE=single && hab pkg install results/${SCAFFOLDING_PKG_ARTIFACT} && build ${plan}/tests/user-linux-include-policy"
)
