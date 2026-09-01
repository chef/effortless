@test "Integration: Chef 19 successfully executes the run from the run hook" {
  result="$(cat /hab/svc/${TEST_PKG_NAME}/test)"
  [ "${result}" = "Hello from Chef 19!" ]
}

@test "Integration: chef-infra-client is version 19.x" {
  result="$(hab pkg path chef/chef-infra-client | grep -oP '(?<=/chef-infra-client/)[\d]+\.\d+\.\d+')"
  [[ "${result}" == 19.* ]]
}

@test "Integration: bootstrap-config.rb pkg_svc_data_path renders" {
  result="$(grep '^cache_path.*' /hab/svc/${TEST_PKG_NAME}/config/bootstrap-config.rb | cut -d/ -f2-3)"
  [ "${result}" = "hab/svc" ]
}

@test "Integration: client-config.rb pkg_svc_data_path renders" {
  result="$(grep '^cache_path.*' /hab/svc/${TEST_PKG_NAME}/config/client-config.rb | cut -d/ -f2-3)"
  [ "${result}" = "hab/svc" ]
}

@test "Integration: scaffold_cacerts SSL_CERT_FILE renders in run hook" {
  result="$(grep '^export SSL_CERT_FILE.*' /hab/svc/${TEST_PKG_NAME}/hooks/run | cut -d/ -f4-5)"
  [ "${result}" = "core/cacerts" ]
}

teardown(){
  if [ "${BATS_TEST_NUMBER}" -eq ${#BATS_TEST_NAMES[@]} ]; then
    hab svc unload "${TEST_PKG_IDENT}" || true
    rm -f /hab/svc/${TEST_PKG_NAME}/test
  fi
}
