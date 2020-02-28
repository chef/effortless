title 'CIS Automate Test'

include_controls 'cis-rhel7-level1-server' do
  skip_control 'xccdf_org.cisecurity.benchmarks_rule_1.1.14_Ensure_nodev_option_set_on_home_partition'
end
