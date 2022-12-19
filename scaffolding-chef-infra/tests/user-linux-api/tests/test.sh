#!/bin/bash
#/ Usage: test.sh <pkg_ident>
#/
#/ Example: test.sh chef/scaffolding-chef-infra/1.2.0/20181108151533
#/

set -euo pipefail

if [[ -z "${1:-}" ]]; then
  grep '^#/' < "${0}" | cut -c4-
	exit 1
fi

TEST_PKG_IDENT="${1}"
export TEST_PKG_IDENT
TEST_PKG_NAME="$(echo "${TEST_PKG_IDENT}" | cut -d/ -f2)"
export TEST_PKG_NAME
source "$(dirname "${0}")/../habitat/plan.sh"
export scaffold_chef_client
export scaffold_cacerts
export pkg_svc_path

hab pkg install core/bats --binlink
hab pkg install "${TEST_PKG_IDENT}"

SUP_WAIT_SECONDS=5

hab sup term
sleep "${SUP_WAIT_SECONDS}"
hab sup run &
echo "Waiting ${SUP_WAIT_SECONDS} seconds for hab sup to start..."
sleep "${SUP_WAIT_SECONDS}"

LOAD_WAIT_SECONDS=30
hab svc load "${TEST_PKG_IDENT}"
echo "Waiting ${LOAD_WAIT_SECONDS} seconds for ${TEST_PKG_IDENT} to start..."
sleep "${LOAD_WAIT_SECONDS}"
bats "$(dirname "${0}")/test.bats"
