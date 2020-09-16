# frozen_string_literal: true

control 'matlab' do
  impact 0.7
  title 'MATLAB installation'
  desc 'check if MATLAB is installed and can connect to license server'

  describe command('matlab') do
    it { should exist }
  end

  describe command(%q{matlab -nodisplay -batch "disp('test')"}) do
    its('exit_status') { should cmp 0 }
  end
end
