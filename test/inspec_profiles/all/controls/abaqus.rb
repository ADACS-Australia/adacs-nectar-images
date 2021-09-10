# frozen_string_literal: true

control 'abaqus' do
  impact 1.0
  title 'ABAQUS installation'
  desc 'check for abaqus executable'

  describe command('abaqus') do
    it { should exist }
  end

  describe command('abaqus help') do
    its('exit_status') { should cmp 0 }
  end
end
