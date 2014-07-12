default['libtool']['version']   = '2.4.2'
default['libtool']['url']       = "http://ftp.gnu.org/gnu/libtool/libtool-#{node['libtool']['version']}.tar.gz"
default['libtool']['make_opts'] = %w{ -j2 }
