# frozen_string_literal: true

control 'ciao' do
  impact 1.0
  title 'CIAO'
  desc 'Check for CIAO installation'

  describe command('alias ciao') do
    its('exit_status') { should eq 0 }
  end

  describe command('ciao') do
    its('exit_status') { should eq 0 }
  end

  describe command('ciao && ahelp -h') do
    its('exit_status') { should eq 0 }
  end
end
