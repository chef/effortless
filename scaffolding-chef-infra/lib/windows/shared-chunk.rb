cache_path '{{pkg.svc_data_path}}/cache'
node_path '{{pkg.svc_data_path}}/nodes'
role_path '{{pkg.svc_data_path}}/roles'
chef_zero.enabled true
ENV['PSModulePath'] = "C:/Program\ Files/WindowsPowerShell/Modules;C:/Windows/system32/WindowsPowerShell/v1.0/Modules;#{ENV['PSModulePath']}"
