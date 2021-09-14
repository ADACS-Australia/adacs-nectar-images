# frozen_string_literal: true

control 'heasoft' do
  impact 1.0
  title 'HEASOFT'
  desc 'Check for HEASOFT installation'

  describe command('fhelp -h') do
    its('exit_status') { should eq 0 }
  end
end
