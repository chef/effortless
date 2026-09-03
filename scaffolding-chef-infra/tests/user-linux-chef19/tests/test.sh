#!/bin/bash
#/ Usage: test.sh <pkg_ident>
#/
#/ Example: test.sh ci/user-linux-chef19/1.0.0/20260827000000
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
export pkg_svc_path

hab pkg install core/bats --binlink
hab pkg install "${TEST_PKG_IDENT}"

hab sup term || true
sleep 1
echo "--- :habicat: Starting the supervisor"
hab sup run &

# A cold VM may need to download chef/hab-launcher (and its deps) before the
# supervisor is actually up, which can take well over a few seconds depending
# on network/architecture. Poll instead of a fixed sleep so we don't race
# `hab svc load` against a supervisor that isn't ready yet.
SUP_TIMEOUT_SECONDS=120
echo "Waiting up to ${SUP_TIMEOUT_SECONDS}s for hab sup to become ready..."
sup_ready=false
for ((i = 0; i < SUP_TIMEOUT_SECONDS; i++)); do
  if hab svc status >/dev/null 2>&1; then
    sup_ready=true
    break
  fi
  sleep 1
done
if [ "${sup_ready}" != "true" ]; then
  echo "ERROR: Supervisor did not become ready within ${SUP_TIMEOUT_SECONDS}s" >&2
  exit 1
fi

hab svc load "${TEST_PKG_IDENT}"

# Similarly, poll for the Chef run to actually converge (the run hook creates
# this file) instead of a fixed sleep, since the first run may also need to
# download core/* deps.
LOAD_TIMEOUT_SECONDS=120
echo "Waiting up to ${LOAD_TIMEOUT_SECONDS}s for ${TEST_PKG_IDENT} to converge..."
svc_ready=false
for ((i = 0; i < LOAD_TIMEOUT_SECONDS; i++)); do
  if [ -f "/hab/svc/${TEST_PKG_NAME}/test" ]; then
    svc_ready=true
    break
  fi
  sleep 1
done
if [ "${svc_ready}" != "true" ]; then
  echo "ERROR: ${TEST_PKG_IDENT} did not converge within ${LOAD_TIMEOUT_SECONDS}s" >&2
  exit 1
fi

bats "$(dirname "${0}")/test.bats"
