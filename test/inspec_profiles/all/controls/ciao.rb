# frozen_string_literal: true

control 'ciao' do
  impact 1.0
  title 'CIAO'
  desc 'Check for CIAO installation'

  ciao = command('alias ciao')

  aliases = [ciao]

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

  ciao_activate = ciao.stdout.match(/\'(.*?)\'/)[0].gsub("'", '')
  describe command("#{ciao_activate} && ahelp -h") do
    its('exit_status') { should eq 0 }
  end
end
