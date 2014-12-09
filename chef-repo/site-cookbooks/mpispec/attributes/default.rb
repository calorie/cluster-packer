default['mpispec']['packages']  = %w{
  libtool
  automake
  autoconf
  binutils
}
default['mpispec']['revision']  = 'master'
default['mpispec']['url']       = "https://github.com/calorie/mpispec/tarball/#{node['mpispec']['revision']}"
default['mpispec']['make_opts'] = []
default['mpispec']['environment'] = { 'C_INCLUDE_PATH' => "#{ENV['C_INCLUDE_PATH']}:/usr/local/openmpi-#{node['openmpi']['version']}" }
