SCAFFOLD_PKG_INSPEC_CLIENT_VERSION="$(echo "${scaffold_inspec_client}" | cut -d/ -f3)"

@test "API: scaffold_cacerts matches run hook core/cacerts" {
  result="$(grep '^export SSL_CERT_FILE.*' /hab/svc/${TEST_PKG_NAME}/hooks/run | cut -d/ -f4-5)"
  [ "${result}" = "core/cacerts" ]
}

@test "API: scaffold_cacerts matches run hook core/cacerts" {
  result="$(grep '^export SSL_CERT_DIR.*' /hab/svc/${TEST_PKG_NAME}/hooks/run | cut -d/ -f4-5)"
  [ "${result}" = "core/cacerts" ]
}

@test "API: scaffold_inspec_client version matches whats in the plan" {
  result="$(hab pkg exec ${TEST_PKG_IDENT} inspec -v | head -n 1 | awk '{print $2}')"
  [ "${result}" = "${SCAFFOLD_PKG_INSPEC_CLIENT_VERSION}" ]
}

teardown(){
  if [ "${BATS_TEST_NUMBER}" -eq ${#BATS_TEST_NAMES[@]} ]; then
    hab svc unload "${TEST_PKG_IDENT}" || true
  fi
}
