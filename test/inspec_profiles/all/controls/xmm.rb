# frozen_string_literal: true

control 'xmm' do
  impact 1.0
  title 'XMM'
  desc 'Check for XMM-SAS installation'

  conda_activate = command('alias conda_activate')
  sas_activate = command('alias sas_activate')

  aliases = [conda_activate, sas_activate]

  aliases.each do |i|
    # Check that the alias exists
    describe i do
      its('exit_status') { should eq 0 }
    end

    # Grep for the actual command the alias defines, since aliases are not expanded in non-interactive ssh
    j = i.stdout.match(/\'(.*?)\'/)[0].gsub("'", '')

    # Check that the alias works
    describe command(j) do
      its('exit_status') { should eq 0 }
    end
  end

  sas = sas_activate.stdout.match(/\'(.*?)\'/)[0].gsub("'", '')
  describe command("#{sas} && sashelp -h") do
    its('exit_status') { should eq 0 }
  end
end
