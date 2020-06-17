apt_packages = [
  'gcc','g++','make',
  'cmake',
  'git',
  'git-lfs',
  'gfortran',
  'nano',
  'emacs',
  'wget'
  ]

py = ['conda','python','ipython']

conda_packages = [
  "python",
  "ipython",
  "numpy",
  "matplotlib",
  "scipy",
  "pandas",
  "tensorflow",
  "astropy",
  "fftw",
  "hdf5",
  "jupyter"
  ]

lsoft = ['ifort','icc','matlab','mathematica','math','idl']

control '1' do
  impact 1.0
  title 'apt installations'
  desc 'Check commands for packages installed with apt'

  apt_packages.each do |package|
      # describe command(package+' --version') do
      #     its('exit_status') { should eq 0 }
      # end
      describe command(package) do
        it {should exist}
      end
  end

end

control '2' do
  impact 1.0
  title 'conda/python installation'
  desc 'Check for installation of conda/python and packages'

  py.each do |j|
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

  lsoft.each do |k|
    describe command(k) do
      it {should exist}
    end
  end

end
