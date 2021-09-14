# frozen_string_literal: true

control 'astro_B' do
  impact 1.0
  title 'ASTRO B Image'
  desc 'Check installation contained in astro B image'

  programs = %w[
    ds9
    sextractor
    fv
  ]

  programs.each do |program|
    describe command(program) do
      it { should exist }
    end
  end

  describe command('sextractor --version') do
    its('exit_status') { should cmp 0 }
  end

  describe command('fhelp -h') do
    its('exit_status') { should eq 0 }
  end

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
