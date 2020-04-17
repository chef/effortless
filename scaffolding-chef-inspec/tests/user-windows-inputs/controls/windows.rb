# encoding: utf-8
# copyright: 2018, The Authors

input('foo_1', value: 'foo_1 defined in profile')
input('foo_2', value: 'foo_2 defined in profile')
input('foo_3', value: '0')

control 'control_1' do
  title 'Control title'
  desc "Control description"
  impact 1.0
  describe file('\test1') do
    its("content"){ should match input('foo_1') }
  end
end

control 'control_2' do
  title 'Control title'
  desc "Control description"
  impact 1.0
  describe file('\test2') do
    its("content"){ should match input('foo_2')}
  end
end


control 'control_3' do
  title 'Control title'
  desc "Control description"
  impact 1.0
  describe file('\test3') do
    its("content"){ should cmp input('foo_3')}
  end
end