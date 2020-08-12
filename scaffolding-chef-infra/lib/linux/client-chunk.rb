cfg_env_path_prefix = '{{cfg.env_path_prefix}}'
cfg_env_path_prefix ||= '/sbin:/usr/sbin:/usr/local/sbin:/usr/local/bin:/usr/bin:/bin'
ENV['PATH'] = "#{cfg_env_path_prefix}:#{ENV['PATH']}"

cfg_ssl_verify_mode = '{{cfg.ssl_verify_mode}}'
cfg_ssl_verify_mode ||= ':verify_peer'
ssl_verify_mode "#{cfg_ssl_verify_mode}"

cfg_rubygems_url = '{{cfg.rubygems_url}}'
cfg_rubygems_url ||= "https://www.rubygems.org"
rubygems_url "#{cfg_rubygems_url}"

cfg_verify_api_cert = '{{cfg.verify_api_cert}}'
cfg_verify_api_cert ||= false
verify_api_cert "#{cfg_verify_api_cert}"

{{#if cfg.automate.enable ~}}
chef_guid '{{sys.member_id}}'
data_collector.token '{{cfg.automate.token}}'
data_collector.server_url '{{cfg.automate.server_url}}'
{{/if ~}}
