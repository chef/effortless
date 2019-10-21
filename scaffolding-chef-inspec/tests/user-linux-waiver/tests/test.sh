#!/bin/sh
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
export pkg_svc_path

hab pkg install core/bats --binlink
hab pkg install "${TEST_PKG_IDENT}"

SUP_WAIT_SECONDS=1

hab sup term
sleep "${SUP_WAIT_SECONDS}"
echo "--- :habicat: Starting the supervisor"
hab sup run &

echo "Waiting ${SUP_WAIT_SECONDS} seconds for hab sup to start..."
sleep "${SUP_WAIT_SECONDS}"

LOAD_WAIT_SECONDS=10
hab svc load "${TEST_PKG_IDENT}"
echo "Waiting ${LOAD_WAIT_SECONDS} seconds for ${TEST_PKG_IDENT} to start..."

function parse_yaml {
   local prefix=$2
   local s='[[:space:]]*' w='[a-zA-Z0-9_]*' fs=$(echo @|tr @ '\034')
   sed -ne "s|^\($s\):|\1|" \
        -e "s|^\($s\)\($w\)$s:$s[\"']\(.*\)[\"']$s\$|\1$fs\2$fs\3|p" \
        -e "s|^\($s\)\($w\)$s:$s\(.*\)$s\$|\1$fs\2$fs\3|p"  $1 |
   awk -F$fs '{
      indent = length($1)/2;
      vname[indent] = $2;
      for (i in vname) {if (i > indent) {delete vname[i]}}
      if (length($3) > 0) {
         vn=""; for (i=0; i<indent; i++) {vn=(vn)(vname[i])("_")}
         printf("%s%s%s=\"%s\"\n", "'$prefix'",vn, $2, $3);
      }
   }'
}

sleep "${LOAD_WAIT_SECONDS}"
bats "$(dirname "${0}")/test.bats"
