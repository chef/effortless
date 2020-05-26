# encoding: utf-8
# copyright: 2018, The Authors

control 'Test Control' do
  title 'Control title'
  desc "Control description"
  impact 1.0
  describe file('/tmp/test') do
    it { should_not exist }
  end
end
