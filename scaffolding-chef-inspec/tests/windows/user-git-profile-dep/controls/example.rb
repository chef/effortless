# encoding: utf-8
# copyright: 2018, The Authors

title 'Windows Baseline'

include_controls 'windows-baseline' do
    skip_control 'cis-network-access-2.2.2'
    skip_control 'windows-account-100'
    skip_control 'cis-act-as-os-2.2.3'
end
