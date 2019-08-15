if [ -z "${scaffold_policy_name+x}" ]; then
  printf "You must set \$scaffold_policy_name to a valid policy name. \\n Try: \$scaffold_policy_name=example"
  exit 1
fi

scaffolding_load() {
  : "${scaffold_chef_client:=chef/chef-client}"
  : "${scaffold_chef_dk:=chef/chef-dk}"
  : "${scaffold_cacerts:=}"
  : "${scaffold_policyfile_path:=$PLAN_CONTEXT/../policyfiles}"
  : "${scaffold_data_bags_path:=$PLAN_CONTEXT/../data_bags}"

  pkg_deps=(
    "${pkg_deps[@]}"
    "${scaffold_chef_client}"
  )
  if [ -n "${scaffold_cacerts}" ]; then
    pkg_deps+=("${scaffold_cacerts}")
  else
    pkg_deps+=("core/cacerts")
  fi

  pkg_build_deps=(
    "${pkg_build_deps[@]}"
    "${scaffold_chef_dk}"
    "core/git"
  )

  pkg_svc_user="root"
  pkg_svc_run="set_just_so_you_will_render"

  # Internals
  : "${lib_dir="$(pkg_path_for "${pkg_scaffolding}")/lib"}"
}

do_default_download() {
  return 0
}

do_default_verify() {
  return 0
}

do_default_unpack() {
  return 0
}

do_default_build_service() {
  mkdir -p "${pkg_prefix}/hooks"
  # Template buildtime variables into the run hook.
  # This allows us to render the run hook from a file.
  sed -e "s,\${scaffold_cacerts},${scaffold_cacerts},g" "${lib_dir}/run.bash" >> "${pkg_prefix}/hooks/run"
  chmod 0750 -R "${pkg_prefix}/hooks"
}

do_default_build() {
  if [ ! -d "${scaffold_policyfile_path}" ]; then
    build_line "A policyfile directory is required to build. More info: https://docs.chef.io/policyfile.html"
    exit 1
  fi

  rm -f "${scaffold_policyfile_path}"/*.lock.json

  policyfile="${scaffold_policyfile_path}/${scaffold_policy_name}.rb"

  for p in $(grep include_policy "${policyfile}" | awk -F "," '{print $1}' | awk -F '"' '{print $2}' | tr -d " "); do
    chef install "${scaffold_policyfile_path}/${p}.rb"
  done

  chef install "${policyfile}"
}

do_default_install() {
  chef export "${scaffold_policyfile_path}/${scaffold_policy_name}.lock.json" "${pkg_prefix}"

  mkdir -p "${pkg_prefix}/config"

  export_chunk=$(cat "${pkg_prefix}/.chef/config.rb")

  shared_chunk=$(cat "${lib_dir}"/shared-chunk.rb)
  shared_chunk=$(echo -e "${export_chunk}\n${shared_chunk}")

  bootstrap_chunk=$(cat "${lib_dir}"/bootstrap-chunk.rb)
  echo -e "${shared_chunk}\n${bootstrap_chunk}" >> "${pkg_prefix}/config/bootstrap-config.rb"

  if $scaffold_report_on_install; then
    if [ -f "$PLAN_CONTEXT/default.toml" ]; then
      echo `grep "^chef_guid" "$PLAN_CONTEXT/default.toml" | sed 's/^chef_guid *= */chef_guid /'` >> "${pkg_prefix}/config/bootstrap-config.rb"
      echo `grep "^token" "$PLAN_CONTEXT/default.toml" | sed 's/^token *= */data_collector.token /'` >> "${pkg_prefix}/config/bootstrap-config.rb"
      echo `grep "^server_url" "$PLAN_CONTEXT/default.toml" | sed 's/^server_url *= */data_collector.server_url /'` >> "${pkg_prefix}/config/bootstrap-config.rb"
    else
      printf "You must have a default.toml file present with the automate section configured..."
      exit 1
    fi
  fi

  client_chunk=$(cat "${lib_dir}"/client-chunk.rb)
  echo -e "${shared_chunk}\n${client_chunk}" >> "${pkg_prefix}/config/client-config.rb"

  cat "${lib_dir}/attributes.json" >> "${pkg_prefix}/config/attributes.json"

  cat "${lib_dir}/default.toml" >> "${pkg_prefix}/default.toml"

  if [ -d "${scaffold_data_bags_path}" ]; then
    cp -a "${scaffold_data_bags_path}" "${pkg_prefix}"
  fi

  rm -rf "${pkg_prefix}/.chef"
  rm "${pkg_prefix}/README.md"
  chmod 0640 -R "${pkg_prefix}/config"
  chmod 0640 "${pkg_prefix}/default.toml"
}

do_default_strip() {
  return 0
}
