require 'yaml'

# Load conda package list from file
conda_packages = input('conda_packages')

control 'conda' do
  impact 1.0
  title 'conda/python installation'
  desc 'Check for installation of conda and packages'

  describe command('conda') do
    it {should exist}
  end

  describe command('conda list') do
    conda_packages.each do |package|
      its('stdout') {should match package}
    end
  end

  # conda_packages.each do |j|
  #   describe command(%Q{conda activate && python -c 'import #{j}'}) do
  #     its('exit_status') {should cmp 0}
  #   end
  # end

end
