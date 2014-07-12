default['autoconf']['version']   = '2.69'
default['autoconf']['url']       = "http://ftp.gnu.org/gnu/autoconf/autoconf-#{node['autoconf']['version']}.tar.gz"
default['autoconf']['make_opts'] = %w{ -j2 }
