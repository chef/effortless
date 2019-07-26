describe package('rsyslog') do
  it { should be_installed }
end

describe package('auditd') do
  it { should be_installed }
end

describe file('/etc/audit/auditd.conf') do
  it { should exist }
end
