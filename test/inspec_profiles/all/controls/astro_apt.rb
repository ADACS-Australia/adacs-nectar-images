# frozen_string_literal: true

control 'astro_apt' do
  impact 1.0
  title 'ASTRO apt packages'
  desc 'Check for astronomy packages installed via apt'

  programs = %w[
    ds9
    sextractor
  ]

  programs.each do |program|
    describe command(program) do
      it { should exist }
    end
  end

  describe command('sextractor --version') do
    its('exit_status') { should cmp 0 }
  end
end
