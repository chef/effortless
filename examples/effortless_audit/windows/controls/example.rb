# encoding: utf-8
# copyright: 2018, The Authors

title 'STIG testing'

include_controls 'stig-windowsserver2016-i-missioncriticalpublic' do
  skip_control 'xccdf_mil.disa.stig_rule_SV-87949r1_rule'
end
