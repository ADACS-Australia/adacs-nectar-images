control 'astro A' do
  impact 1.0
  title 'ASTRO A Image'
  desc 'Check installation contained in astro A image'

  programs = [
    "ds9",
    "sextractor",
    "fv"
  ]

  programs.each do |program|
    describe command(program) do
      it { should exist }
    end
  end

  describe command("sextractor --version") do
    its('exit_status') {should cmp 0}
  end

  envs = [
    "astroconda ",
    "dragons    ",
    "fermi      ",
    "geminiconda",
    "iraf27     ",
    "pywifes"
  ]

  describe command('conda env list') do
    envs.each do |env|
      its('stdout') {should match env}
    end
  end

  envs.each do |env|
    describe command("conda activate #{env}") do
      its('exit_status') { should eq 0 }
    end
  end

end
