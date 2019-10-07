#!/bin/bash

set -eou pipefail

plan="$(basename "${1}")"
test_plan="$(basename "${2}")"
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
  echo "--- :construction: :linux: Building ci/cacerts plan"
  hab studio -q -r "/hab/studios/ci-cacerts-${SCAFFOLDING_PKG_RELEASE}" run "build ${plan}/tests/cacerts"
  source results/last_build.env # cacerts last_build.env
  CACERTS_PKG_ARTIFACT="${pkg_artifact}"

  echo "--- :construction: :linux: Building ${test_plan} user plan for ${plan}"
  hab studio -q -r "/hab/studios/default-${SCAFFOLDING_PKG_RELEASE}" run "hab pkg install results/${SCAFFOLDING_PKG_ARTIFACT} && build ${plan}/tests/${test_plan}"
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

  hab studio -q -r "/hab/studios/default-${TEST_PKG_RELEASE}" run "hab pkg install results/${TEST_PKG_ARTIFACT} && ./${plan}/tests/${test_plan}/tests/test.sh ${TEST_PKG_IDENT}"
)
