patch_sentinel = File.join(Chef::Config.file_cache_path, "chef_patching_sentinel")

case node['platform']
when 'debian', 'ubuntu'
  apt_update
  execute 'apt-get upgrade -y'
  file patch_sentinel do
    mode "0600"
    content "#{node['patching']['patchlevel']}"
  end

when 'redhat', 'centos', 'fedora', 'amazon'
  execute 'yum update -y'
  file patch_sentinel do
    mode "0600"
    content "#{node['patching']['patchlevel']}"
  end
end
