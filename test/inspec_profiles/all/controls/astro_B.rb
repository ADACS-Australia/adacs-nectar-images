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
end
