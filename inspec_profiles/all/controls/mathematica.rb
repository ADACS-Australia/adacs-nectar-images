control 'mathematica' do
  impact 0.7
  title 'mathematica installation'
  desc 'check if mathematica is installed and can connect to license server'

  describe command('mathematica') do
    it {should exist}
  end

  describe command(%q{echo | math}) do
    its('exit_status') {should cmp 0}
  end

end
