node.default['security_policy']['rights']['SeNetworkLogonRight'] = nil
node.default['security_policy']['rights']['SeRemoteInteractiveLogonRight'] = nil
node.default['security_policy']['rights']['SeTrustedCredManAccessPrivilege'] = nil
include_recipe 'windows-hardening'
