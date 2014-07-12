default['gcc']['version']       = '4.9.0'
default['gcc']['url']           = "http://ftp.gnu.org/gnu/gcc/gcc-#{node['gcc']['version']}/gcc-#{node['gcc']['version']}.tar.gz"
default['gcc']['autoconf_opts'] = %w{ --disable-bootstrap }
default['gcc']['make_opts']     = %w{ -j2 }
default['gcc']['environment']   = {}
