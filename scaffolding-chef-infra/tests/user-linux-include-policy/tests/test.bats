@test "Build: Chef successfully executes the run from the run hook" {
  result="$(cat /hab/svc/${TEST_PKG_NAME}/test)"
  [ "${result}" = "Hello world!" ]
}

teardown(){
  if [ "${BATS_TEST_NUMBER}" -eq ${#BATS_TEST_NAMES[@]} ]; then
    hab svc unload "${TEST_PKG_IDENT}" || true
    rm /hab/svc/${TEST_PKG_NAME}/test
  fi
}
