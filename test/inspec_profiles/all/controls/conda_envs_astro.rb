# frozen_string_literal: true

control 'conda_envs_astro' do
  impact 1.0
  title 'Astronomy conda environments'
  desc 'Check for anaconda astronomy environments'

  envs = [
    'astroconda ',
    'dragons    ',
    'fermi      ',
    'geminiconda',
    'iraf27     ',
    'pywifes'
  ]

  describe command('conda env list') do
    envs.each do |env|
      its('stdout') { should match env }
    end
  end

  envs.each do |env|
    describe command("conda activate #{env}") do
      its('exit_status') { should eq 0 }
    end
  end
end
