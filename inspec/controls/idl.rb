control 'idl' do
  impact 0.7
  title 'IDL installation'
  desc 'check if IDL is installed and can connect to license server'

  describe command('idl') do
    it {should exist}
  end

  describe command(%q{idl -e 'print, ""'}) do
    its('stdout') {should eq "\n"}
    its('exit_status') { should eq 0 }
  end

end
