default['openmpi']['compile'] = true
default['openmpi']['debian']  = %w(openmpi-bin libopenmpi-dev)

default['openmpi']['version']   = '1.8.4'
default['openmpi']['url']       = "http://www.open-mpi.org/software/ompi/v1.8/downloads/openmpi-#{node['openmpi']['version']}.tar.gz"
default['openmpi']['prefix']    = '/usr/local'
default['openmpi']['conf_opts'] = %w{
  --disable-dependency-tracking
  --disable-silent-rules
  --disable-mpi-fortran
  --disable-mpi-cxx
  --with-devel-headers
}
default['openmpi']['make_opts'] = []
default['openmpi']['dependencies'] = %w{
  autotools-dev
  automake
}
