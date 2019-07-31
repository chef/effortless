# encoding: utf-8
# copyright: 2018, The Authors

title 'Linux Baseline'


# TO DO - There is a know issue with Centos7 for ryslog and auditd package controls.
# once the community cookbook has been updated we can add the skipped controls back
include_controls 'linux-baseline' do 
  skip_control 'package-07'
  skip_control 'package-08'
  skip_control 'sysctl-33'
end


include_controls 'linux-patch-baseline'