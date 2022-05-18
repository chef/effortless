SCAFFOLD_PKG_INSPEC_CLIENT_VERSION="$(echo "${scaffold_inspec_client}" | cut -d/ -f3)"

assert_file_exist() {
  local -r file="$1"
  if [[ ! -e "$file" ]]; then
    fail
  fi
}

@test "API: scaffold_cacerts matches run hook core/cacerts" {
  result="$(grep '^export SSL_CERT_FILE.*' /hab/svc/${TEST_PKG_NAME}/hooks/run | cut -d/ -f4-5)"
  [ "${result}" = "core/cacerts" ]
}

@test "API: scaffold_cacerts matches run hook core/cacerts" {
  result="$(grep '^export SSL_CERT_DIR.*' /hab/svc/${TEST_PKG_NAME}/hooks/run | cut -d/ -f4-5)"
  [ "${result}" = "core/cacerts" ]
}

@test "API: setting a json output creates a json file." {
  assert_file_exist /hab/svc/${TEST_PKG_NAME}/results.json
}

teardown(){
  if [ "${BATS_TEST_NUMBER}" -eq ${#BATS_TEST_NAMES[@]} ]; then
    hab svc unload "${TEST_PKG_IDENT}" || true
  fi
}
