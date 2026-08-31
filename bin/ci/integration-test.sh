#!/bin/bash
#
# Integration test: chef/scaffolding-chef-infra + chef/chef-infra-client (Linux)
#
# PURPOSE:
#   The verify pipeline (verify.scaffolding-chef-infra.yml) tests scaffolding
#   built FROM SOURCE on every PR using a fake 'ci' origin. This pipeline tests
#   the PUBLISHED scaffolding package (just promoted to unstable by habitat/build)
#   against the LATEST chef-infra-client from unstable. It catches integration
#   issues before packages are promoted to base-2025 for release.
#
# TRIGGER:
#   Triggered automatically via the buildkite_hab_build_group_published workload
#   subscription in .expeditor/config.yml, immediately after the habitat/build
#   pipeline publishes scaffolding packages to the unstable channel on Builder.
#
# CHANNEL STRATEGY:
#   chef/scaffolding-chef-infra  ->  latest from unstable (just published by habitat/build)
#   chef/chef-infra-client       ->  latest from unstable (pre-installed before build)
#   core/* and all other deps    ->  base-2025 (stable, prevents flakiness from
#                                    unrelated core package churn in unstable)
#
#   This mirrors the post-release state: users consume scaffolding and
#   chef-infra-client from base-2025. Testing against unstable for chef-owned
#   packages validates the upcoming release combination before it lands in base-2025.
#
# HOW IT WORKS (Linux bind-mount trick):
#   Linux Habitat studios bind-mount the host's /hab/pkgs into the studio.
#   By pre-installing exact package idents from unstable on the HOST before
#   starting the studio, those packages are visible inside the studio at build time.
#   The build then runs with HAB_BLDR_CHANNEL=base-2025, so:
#     - Habitat finds the pre-installed exact idents in the bind-mounted cache
#       and uses them directly without querying Builder for those packages
#     - All other dependencies (core/*) are resolved from base-2025 as normal
#   The exact idents are injected into the studio via HAB_STUDIO_SECRET_* so that
#   the test plan's plan.sh can pin pkg_scaffolding and scaffold_chef_client to them.
#
# USAGE:
#   Normally invoked by the Buildkite integration-test pipeline. Can also be run
#   locally with HAB_AUTH_TOKEN set:
#     HAB_AUTH_TOKEN=<token> ./bin/ci/integration-test.sh scaffolding-chef-infra user-linux-chef19 ci
#

set -eou pipefail

plan="$(basename "${1}")"
test_plan="$(basename "${2}")"
chef_policy_name="$(basename "${3}")"
export HAB_ORIGIN=ci
export HAB_BLDR_CHANNEL="${HAB_BLDR_CHANNEL:-base-2025}"
UNSTABLE_CHANNEL="unstable"

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
export HAB_STUDIO_SECRET_HAB_AUTH_TOKEN="${HAB_AUTH_TOKEN}"
export HAB_STUDIO_SECRET_HAB_BLDR_CHANNEL="${HAB_BLDR_CHANNEL}"
export HAB_STUDIO_SECRET_GIT_CONFIG_COUNT=1
export HAB_STUDIO_SECRET_GIT_CONFIG_KEY_0=safe.directory
export HAB_STUDIO_SECRET_GIT_CONFIG_VALUE_0='*'

echo "--- :habicat: Installing Habitat"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
"${SCRIPT_DIR}/install-hab.sh" x86_64-linux

echo "--- :key: Generating fake origin key"
hab origin key generate "${HAB_ORIGIN}"

if type git 2>/dev/null; then
  echo "--- :thumbsup: git's installed"
else
  echo "--- :hammer_and_wrench: Installing git"
  hab pkg install core/git --binlink
fi
project_root="$(git rev-parse --show-toplevel)"

echo "--- :habicat: Pre-installing chef/scaffolding-chef-infra from ${UNSTABLE_CHANNEL}"
# Install from unstable so the package lands in the host's /hab/pkgs, which is
# bind-mounted into the Linux studio. After install, capture the exact 4-part
# ident so the test plan pins to this specific version rather than re-resolving.
HAB_BLDR_CHANNEL="${UNSTABLE_CHANNEL}" hab pkg install chef/scaffolding-chef-infra \
  --channel "${UNSTABLE_CHANNEL}"
SCAFFOLDING_IDENT="$(hab pkg path chef/scaffolding-chef-infra | sed 's|^/hab/pkgs/||')"
echo "    Resolved scaffolding: ${SCAFFOLDING_IDENT}"

echo "--- :habicat: Pre-installing chef/chef-infra-client from ${UNSTABLE_CHANNEL}"
HAB_BLDR_CHANNEL="${UNSTABLE_CHANNEL}" hab pkg install chef/chef-infra-client \
  --channel "${UNSTABLE_CHANNEL}"
CHEF_CLIENT_IDENT="$(hab pkg path chef/chef-infra-client | sed 's|^/hab/pkgs/||')"
echo "    Resolved chef-infra-client: ${CHEF_CLIENT_IDENT}"

# Inject exact idents into the studio so plan.sh can pin to them.
# HAB_STUDIO_SECRET_INTEGRATION_SCAFFOLDING_IDENT becomes INTEGRATION_SCAFFOLDING_IDENT
# inside the studio, used by pkg_scaffolding in the test plan's plan.sh.
export HAB_STUDIO_SECRET_INTEGRATION_SCAFFOLDING_IDENT="${SCAFFOLDING_IDENT}"
export HAB_STUDIO_SECRET_INTEGRATION_CHEF_CLIENT_IDENT="${CHEF_CLIENT_IDENT}"

echo "--- :construction: Building ${test_plan}"
echo "    scaffolding:        ${SCAFFOLDING_IDENT}"
echo "    chef-infra-client:  ${CHEF_CLIENT_IDENT}"
echo "    dep channel:        ${HAB_BLDR_CHANNEL}"

(cd "${project_root}" || exit 1
  # Build the test user package with base-2025 as the resolver channel.
  # The scaffolding and chef-infra-client are already in /hab/pkgs (bind-mounted
  # from the pre-install steps above), so Habitat uses the cached exact idents.
  # All core/* and other deps are resolved from base-2025.
  hab pkg build "${plan}/tests/${test_plan}" --refresh-channel "${HAB_BLDR_CHANNEL}"

  source results/last_build.env
  TEST_PKG_RELEASE="${pkg_release}"
  TEST_PKG_ARTIFACT="${pkg_artifact}"
  TEST_PKG_IDENT="${pkg_ident}"

  echo "--- :mag: Testing ${TEST_PKG_IDENT}"
  if [ ! -f "${plan}/tests/${test_plan}/tests/test.sh" ]; then
    buildkite-agent annotate --style 'warning' ":warning: :linux: ${test_plan} has no tests to run."
    exit 0
  fi

  hab studio -q -r "/hab/studios/${test_plan}-${TEST_PKG_RELEASE}" run \
    "export CHEF_POLICYFILE=${chef_policy_name} && hab pkg install results/${TEST_PKG_ARTIFACT} && ./${plan}/tests/${test_plan}/tests/test.sh ${TEST_PKG_IDENT}"
)
