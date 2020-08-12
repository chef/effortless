cache_path '{{pkg.svc_data_path}}/cache'
node_path '{{pkg.svc_data_path}}/nodes'
role_path '{{pkg.svc_data_path}}/roles'

cfg_env_path_prefix = '{{cfg.env_path_prefix}}'
cfg_env_path_prefix ||= ";C:/WINDOWS;C:/WINDOWS/system32/;C:/WINDOWS/system32/WindowsPowerShell/v1.0;C:/ProgramData/chocolatey/bin"
ENV['PATH'] += cfg_env_path_prefix

cfg_ssl_verify_mode = '{{cfg.ssl_verify_mode}}'
cfg_ssl_verify_mode ||= ":verify_peer"
ssl_verify_mode "#{cfg_ssl_verify_mode}"

cfg_rubygems_url = '{{cfg.rubygems_url}}'
cfg_rubygems_url ||= "https://www.rubygems.org"
rubygems_url "#{rubygems_url}"

cfg_verify_api_cert = '{{cfg.verify_api_cert}}'
cfg_verify_api_cert ||= false
verify_api_cert "#{cfg_verify_api_cert}"

{{#if cfg.automate.enable ~}}
chef_guid "{{sys.member_id}}"
data_collector.token "{{cfg.automate.token}}"
data_collector.server_url "{{cfg.automate.server_url}}"
{{/if ~}}
