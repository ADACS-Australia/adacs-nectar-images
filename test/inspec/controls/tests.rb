require 'yaml'

# Load apt package list from file
apt_packages=YAML.load_file('../../ansible/vars/apt_packages.yml')['apt_packages']
apt_packages.delete_if{|i| i == 'build-essential'}
apt_packages.concat(['gcc','g++','make'])

# Load conda package list from file
conda_packages=YAML.load_file('../../ansible/vars/conda_packages.yml')['conda_packages']
python = ['conda','python','ipython']

licensed_software = ['ifort','icc','matlab','mathematica','math','idl']

control '1' do
  impact 1.0
  title 'apt installations'
  desc 'Check commands for packages installed with apt'

  apt_packages.each do |package|
      describe command(package) do
        it {should exist}
      end
  end

end

control '2' do
  impact 1.0
  title 'conda/python installation'
  desc 'Check for installation of conda/python and packages'

  python.each do |j|
    describe command(j) do
      it {should exist}
    end
  end

  describe command('conda list') do
    conda_packages.each do |package|
      its('stdout') {should match package}
    end
  end

end

control '3' do
  impact 0.7
  title 'Licensed software installations'
  desc 'Check for installations of licensed software'

  licensed_software.each do |k|
    describe command(k) do
      it {should exist}
    end
  end

end
