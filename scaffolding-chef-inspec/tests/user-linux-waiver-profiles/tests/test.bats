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

@test "API: scaffold_cacerts matches run hook core/cacerts" {
  result="$(grep '^export SSL_CERT_FILE.*' /hab/svc/${TEST_PKG_NAME}/hooks/run | cut -d/ -f4-5)"
  [ "${result}" = "core/cacerts" ]
}

@test "API: scaffold_cacerts matches run hook core/cacerts" {
  result="$(grep '^export SSL_CERT_DIR.*' /hab/svc/${TEST_PKG_NAME}/hooks/run | cut -d/ -f4-5)"
  [ "${result}" = "core/cacerts" ]
}

@test "Waiver: Ensure waiver file is written correctly" {
  result="$(parse_yaml /hab/svc/user-linux-waiver-profiles/config/waiver.yml| grep 'foo_2_run')"
  [ "${result}" = "foo_2_run=\"false\"" ]
}

teardown(){
  if [ "${BATS_TEST_NUMBER}" -eq ${#BATS_TEST_NAMES[@]} ]; then
    hab svc unload "${TEST_PKG_IDENT}" || true
  fi
}
