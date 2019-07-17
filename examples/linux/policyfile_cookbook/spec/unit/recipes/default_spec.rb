require 'spec_helper'

describe 'policyfile_cookbook::default' do
  context 'When all attributes are default, on Ubuntu' do
    platform 'ubuntu'

    it { is_expected.to create_file('/tmp/example_file') }
  end
end
