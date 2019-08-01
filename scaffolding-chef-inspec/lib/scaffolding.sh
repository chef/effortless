#
# A scaffolding for an InSpec Profile
#

scaffolding_load() {
  : "${scaffold_automate_server_url:=}"
  : "${scaffold_automate_user:=}"
  : "${scaffold_automate_token:=}"
  : "${scaffold_cacerts:=}"

  pkg_deps=(
    "${pkg_deps[@]}"
    "chef/inspec"
  )
  if [ -n "${scaffold_cacerts}" ]; then
    pkg_deps+=("${scaffold_cacerts}")
  else
    pkg_deps+=("core/cacerts")
  fi

  pkg_build_deps=(
    "${pkg_build_deps[@]}"
    "chef/inspec"
  )
  pkg_svc_user="root"
  pkg_svc_run="set_just_so_you_will_render"
}

do_default_before() {
  if [ ! -f "$PLAN_CONTEXT/../inspec.yml" ]; then
    message="ERROR: Cannot find inspec.yml."
    message="$message Please build from the profile root"
    build_line "$message"

    exit 1
  fi

  # Execute an 'inspec compliance login' if a profile needs to be fetched from
  # the Automate server
  if [ "$(grep "compliance: " "$PLAN_CONTEXT/../inspec.yml")" ]; then
    if [ ! $scaffold_automate_server_url ]; then
      message="You have a dependency on a profile in Automate"
      message="$message please specify the \$scaffold_automate_server_url"
      message="$message in your plan.sh file."
      build_line "$message"
      exit 1
    elif [ ! $scaffold_automate_user ]; then
      message="You have a dependency on a profile in Automate"
      message="$message please specify the \$scaffold_automate_user"
      message="$message in your plan.sh file."
      build_line "$message"
      exit 1
    elif [ ! $scaffold_automate_token ]; then
      message="You have a dependency on a profile in Automate"
      message="$message please specify the \$scaffold_automate_token"
      message="$message in your plan.sh file."
      build_line "$message"
      exit 1
    else
      inspec compliance login $scaffold_automate_server_url \
                              --user $scaffold_automate_user \
                              --token $scaffold_automate_token
    fi
  fi
}

do_default_setup_environment() {
  set_buildtime_env PROFILE_CACHE_DIR "$HAB_CACHE_SRC_PATH/$pkg_dirname"
  set_buildtime_env ARCHIVE_NAME "$pkg_name-$pkg_version.tar.gz"

  # InSpec loads `pry` which tries to expand `~`. This fails if HOME isn't set.
  set_runtime_env HOME "$pkg_svc_var_path"

  # InSpec will create a `.inspec` directory in the user's home directory.
  # This overrides that to write to a place within the running service's path.
  # NOTE: Setting HOME does the same currently. This is here to be explicit.
  set_runtime_env INSPEC_CONFIG_DIR  "$pkg_svc_var_path"
}

do_default_unpack() {
  # Change directory to where the profile files are
  pushd "$PLAN_CONTEXT/../" > /dev/null

  # Get a list of all files in the profile except those that are Habitat related
  profile_files=($(ls -I habitat -I results -I "*.hart"))

  mkdir -p "$HAB_CACHE_SRC_PATH/$pkg_dirname" > /dev/null

  # Copy just the profile files to the profile cache directory
  cp -r ${profile_files[@]} "$HAB_CACHE_SRC_PATH/$pkg_dirname"
}

do_default_build_service() {
  ## Create Hooks
  mkdir -p "$pkg_prefix/hooks"
  chmod 0750 "$pkg_prefix/hooks"

  # Run hook
  cat << EOF >> "$pkg_prefix/hooks/run"
#!/bin/sh

export HOME="{{pkg.svc_var_path}}"
export INSPEC_CONFIG_DIR="{{pkg.svc_var_path}}"
export SSL_CERT_FILE="{{ pkgPathFor "${CFG_CACERTS:-core/cacerts}" }}/ssl/cert.pem"
export SSL_CERT_DIR="{{ pkgPathFor "${CFG_CACERTS:-core/cacerts}" }}/ssl/certs"

CFG_SPLAY_FIRST_RUN={{cfg.splay_first_run}}
CFG_SPLAY_FIRST_RUN="\${CFG_SPLAY_FIRST_RUN:-0}"
CFG_INTERVAL={{cfg.interval}}
CFG_INTERVAL="\${CFG_INTERVAL:-1800}"
CFG_SPLAY={{cfg.splay}}
CFG_SPLAY="\${CFG_SPLAY:-1800}"
CFG_LOG_LEVEL={{cfg.log_level}}
CFG_LOG_LEVEL="\${CFG_LOG_LEVEL:-warn}"
CFG_CHEF_LICENSE={{cfg.chef_license.acceptance}}
CFG_CHEF_LICENSE="\${CFG_CHEF_LICENSE:-undefined}"
CONFIG="{{pkg.svc_config_path}}/inspec_exec_config.json"
PROFILE_PATH="{{pkg.path}}/{{pkg.name}}-{{pkg.version}}.tar.gz"

inspec_cmd()
{
  inspec exec \${PROFILE_PATH} --config \${CONFIG} --chef-license \$CFG_CHEF_LICENSE --log-level \$CFG_LOG_LEVEL
}


SPLAY_DURATION=\$(shuf -i 0-\$CFG_SPLAY -n 1)
SPLAY_FIRST_RUN_DURATION=\$(shuf -i 0-\$CFG_SPLAY_FIRST_RUN -n 1)

exec 2>&1
sleep \$SPLAY_FIRST_RUN_DURATION
inspec_cmd

while true; do
  SLEEP_TIME=\$((\$SPLAY_DURATION + \$CFG_INTERVAL))
  echo "InSpec is sleeping for \$SLEEP_TIME seconds"
  sleep \$SPLAY_DURATION
  sleep \$CFG_INTERVAL
  inspec_cmd
done
EOF
  chmod 0750 "$pkg_prefix/hooks/run"
}

do_default_build() {
  inspec archive "$HAB_CACHE_SRC_PATH/$pkg_dirname" \
                 --overwrite \
                 -o "$HAB_CACHE_SRC_PATH/$pkg_dirname/$pkg_name-$pkg_version.tar.gz" \
                 --chef-license "$CHEF_LICENSE"
}

do_default_install() {
  cp "$HAB_CACHE_SRC_PATH/$pkg_dirname/$pkg_name-$pkg_version.tar.gz" "$pkg_prefix"

  mkdir -p "$pkg_prefix/config"
  chmod 0750 "$pkg_prefix/config"
  cat << EOF >> "$pkg_prefix/config/cli_only.json"
{
    "reporter": {
        "cli" : {
            "stdout" : true
        }
    }
}
EOF
  chmod 0640 "$pkg_prefix/config/cli_only.json"

  cat << EOF >> "$pkg_prefix/config/inspec_exec_config.json"
{
    "target_id": "{{ sys.member_id }}",
    "reporter": {
      "cli": {
        "stdout": true
      },
      "json": {
        "file": "{{pkg.svc_path}}/logs/inspec_last_run.json"
      }{{#if cfg.automate.enable ~}},
      "automate" : {
        "url": "{{cfg.automate.server_url}}/data-collector/v0/",
        "token": "{{cfg.automate.token}}",
        "node_name": "{{ sys.hostname }}",
        "verify_ssl": false
      }{{/if ~}}
    }
    {{#if cfg.automate.enable }},
    "compliance": {
     "server" : "{{cfg.automate.server_url}}",
     "token" : "{{cfg.automate.token}}",
     "user" : "{{cfg.automate.user}}",
     "insecure" : true,
     "ent" : "automate"
    }{{/if }}
}
EOF
  chmod 0640 "$pkg_prefix/config/inspec_exec_config.json"

  cat << EOF >> "$pkg_prefix/default.toml"
# You must accept the Chef License to use this software: https://www.chef.io/end-user-license-agreement/
# Change [chef_license] from acceptance = "undefined" to acceptance = "accept-no-persist" if you agree to the license.

interval = 1800
splay = 1800
splay_first_run = 0
log_level = 'warn'

[chef_license]
acceptance = "undefined"

[automate]
enable = false
server_url = 'https://<automate_url>'
token = '<automate_token>'
user = '<automate_user>'
EOF
  chmod 0640 "$pkg_prefix/default.toml"
}

do_default_strip() {
  return 0
}
