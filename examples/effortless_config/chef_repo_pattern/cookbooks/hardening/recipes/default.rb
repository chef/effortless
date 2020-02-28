#
# Cookbook:: hardening
# Recipe:: default
#
# Copyright:: 2020, The Authors, All Rights Reserved.

if node['os'] == 'linux'
  include_recipe 'os-hardening::default'
  include_recipe 'hardening::remediation'
elsif node['os'] == 'windows'
  node.default['security_policy']['rights']['SeNetworkLogonRight'] = nil
  node.default['security_policy']['rights']['SeRemoteInteractiveLogonRight'] = nil
  node.default['security_policy']['rights']['SeTrustedCredManAccessPrivilege'] = nil
  include_recipe 'windows-hardening'
end
