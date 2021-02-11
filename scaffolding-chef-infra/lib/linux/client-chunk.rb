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

{{# if cfg.blocked_automatic_attributes ~}}
blocked_automatic_attributes {{cfg.blocked_automatic_attributes}}
{{/if ~}}

{{# if cfg.blocked_default_attributes ~}}
blocked_default_attributes {{cfg.blocked_default_attributes}}
{{/if ~}}

{{# if cfg.blocked_normal_attributes ~}}
blocked_normal_attributes {{cfg.blocked_normal_attributes}}
{{/if ~}}

{{# if cfg.blocked_override_attributes ~}}
blocked_override_attributes {{cfg.blocked_override_attributes}}
{{/if ~}}

{{# if cfg.allowed_automatic_attributes ~}}
allowed_automatic_attributes {{cfg.allowed_automatic_attributes}}
{{/if ~}}

{{# if cfg.blocked_automatic_attributes ~}}
blocked_automatic_attributes {{cfg.blocked_automatic_attributes}}
{{/if ~}}

{{# if cfg.allowed_default_attributes ~}}
allowed_default_attributes {{cfg.allowed_default_attributes}}
{{/if ~}}

{{# if cfg.allowed_normal_attributes ~}}
allowed_normal_attributes {{cfg.allowed_normal_attributes}}
{{/if ~}}

{{# if cfg.allowed_override_attributes ~}}
allowed_override_attributes {{cfg.allowed_override_attributes}}
{{/if ~}}
