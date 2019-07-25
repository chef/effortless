SCAFFOLD_PKG_VERSION="$(echo "${scaffold_chef_client}" | cut -d/ -f3)"

teardown(){
  hab svc unload "${TEST_PKG_IDENT}" || true
}

@test "API: scaffold_chef_client version matches hab pkg exec version" {
  result="$(hab pkg exec ${TEST_PKG_IDENT} chef-client -v | head -n 1 | awk '{print $2}')"
  [ "$result" = "${SCAFFOLD_PKG_VERSION}" ]
}
