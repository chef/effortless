
package "rsyslog"

case node['platform']
when 'debian', 'ubuntu'
  # The `apt-update` resource is responsible for ensuring the apt cache is refreshed before installing packages.
  # To ensure that the latest packages are running, see the 'patching' cookbook and the `apt upgrade -y` command.
  # Further information available at: https://docs.chef.io/resource_apt_update.html
  apt_update
  package "auditd"
  package 'haveged'
when 'redhat', 'centos', 'fedora', 'amazon'
  package "audit"
end

cookbook_file "/etc/audit/auditd.conf" do
  source "auditd.conf"
end
