#!/bin/sh

export SSL_CERT_FILE="{{ pkgPathFor "${scaffold_cacerts}" }}/ssl/cert.pem"
export SSL_CERT_DIR="{{ pkgPathFor "${scaffold_cacerts}" }}/ssl/certs"

cfg_interval={{cfg.interval}}
cfg_interval="${cfg_interval:-1800}"
cfg_log_level={{cfg.log_level}}
cfg_log_level="${cfg_log_level:-warn}"
cfg_run_lock_timeout={{cfg.run_lock_timeout}}
cfg_run_lock_timeout="${cfg_run_lock_timeout:-1800}"
cfg_splay={{cfg.splay}}
cfg_splay="${cfg_splay:-1800}"
cfg_splay_first_run={{cfg.splay_first_run}}
cfg_splay_first_run="${cfg_splay_first_run:-0}"
cfg_chef_license={{cfg.chef_license.acceptance}}
cfg_chef_license="${cfg_chef_license:-undefined}"

chef_client_cmd()
{
  chef-client -z -l "${cfg_log_level}" -c {{pkg.svc_config_path}}/client-config.rb -j {{pkg.svc_config_path}}/attributes.json --once --no-fork --run-lock-timeout "${cfg_run_lock_timeout}" --chef-license "${cfg_chef_license}"
}

cfg_splay_duration=$(shuf -i 0-"${cfg_splay}" -n 1)

cfg_splay_first_run_duration=$(shuf -i 0-"${cfg_splay_first_run}" -n 1)

cd {{pkg.path}}

exec 2>&1
sleep "${cfg_splay_first_run_duration}"
chef_client_cmd

while true; do
  sleep "${cfg_splay_duration}"
  sleep "${cfg_interval}"
  chef_client_cmd
done
