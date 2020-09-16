# frozen_string_literal: true

apt_packages = [
  'gcc',
  'g++',
  'make',
  'cmake',
  'git',
  'git-lfs',
  'gfortran',
  'nano',
  'emacs',
  'wget',
  'python'
]

control 'basic' do
  impact 1.0
  title 'basic items'
  desc 'check for a list of commands that should be available on any image'

  apt_packages.each do |package|
    describe command(package) do
      it { should exist }
    end
  end
end
