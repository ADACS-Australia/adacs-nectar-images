# frozen_string_literal: true

control 'xmm' do
  impact 1.0
  title 'XMM'
  desc 'Check for XMM-SAS installation'

  describe command('alias conda_activate') do
    its('exit_status') { should eq 0 }
  end

  describe command('conda_activate') do
    its('exit_status') { should eq 0 }
  end

  describe command('alias sas_activate') do
    its('exit_status') { should eq 0 }
  end

  describe command('sas_activate') do
    its('exit_status') { should eq 0 }
  end

  describe command('sas_activate && sashelp -h') do
    its('exit_status') { should eq 0 }
  end
end
