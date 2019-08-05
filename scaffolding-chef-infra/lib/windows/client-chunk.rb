cfg_env_path_prefix = {{cfg.env_path_prefix}}
cfg_env_path_prefix ||= ";C:/WINDOWS;C:/WINDOWS/system32/;C:/WINDOWS/system32/WindowsPowerShell/v1.0;C:/ProgramData/chocolatey/bin"
ENV['PATH'] += cfg_env_path_prefix

cfg_ssl_verify_mode = {{cfg.ssl_verify_mode}}
cfg_ssl_verify_mode ||= ":verify_peer"
ssl_verify_mode "#{cfg_ssl_verify_mode}"

{{#if cfg.automate.enable ~}}
chef_guid "{{sys.member_id}}"
data_collector.token "{{cfg.automate.token}}"
data_collector.server_url "{{cfg.automate.server_url}}"
{{/if ~}}
