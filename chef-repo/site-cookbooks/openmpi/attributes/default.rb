default['openmpi']['package'] = false
default['openmpi']['debian']  = %w(openmpi-bin libopenmpi-dev)

default['openmpi']['version']   = '1.8.3'
default['openmpi']['url']       = "http://www.open-mpi.org/software/ompi/v1.8/downloads/openmpi-#{node['openmpi']['version']}.tar.gz"
default['openmpi']['prefix']    = '/usr/local'
default['openmpi']['make_opts'] = []
default['openmpi']['packages']  = %w{
  autotools-dev
  autoconf
  automake
  g++
  gfortran
  build-essential
  flex
}
