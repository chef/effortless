@test "Build: Chef successfully executes the run from the run hook" {
  result="$(cat /hab/svc/${TEST_PKG_NAME}/test)"
  [ "${result}" = "Hello world!" ]
}

@test "Build: bootstrap-config.rb pkg_svc_data_path renders" {
  result="$(grep '^cache_path.*' /hab/svc/${TEST_PKG_NAME}/config/bootstrap-config.rb | cut -d/ -f2-3)"
  [ "${result}" = "hab/svc" ]
}

@test "Build: client-config.rb pkg_svc_data_path renders" {
  result="$(grep '^cache_path.*' /hab/svc/${TEST_PKG_NAME}/config/client-config.rb | cut -d/ -f2-3)"
  [ "${result}" = "hab/svc" ]
}

@test "API: scaffold_cacerts matches run hook core/cacerts" {
  result="$(grep '^export SSL_CERT_FILE.*' /hab/svc/${TEST_PKG_NAME}/hooks/run | cut -d/ -f4-5)"
  [ "${result}" = "core/cacerts" ]
}

@test "API: scaffold_cacerts matches run hook core/cacerts" {
  result="$(grep '^export SSL_CERT_DIR.*' /hab/svc/${TEST_PKG_NAME}/hooks/run | cut -d/ -f4-5)"
  [ "${result}" = "core/cacerts" ]
}

teardown(){
  if [ "${BATS_TEST_NUMBER}" -eq ${#BATS_TEST_NAMES[@]} ]; then
    hab svc unload "${TEST_PKG_IDENT}" || true
    rm /hab/svc/user-linux-default/test
  fi
}
