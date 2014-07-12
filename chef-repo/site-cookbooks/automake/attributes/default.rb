default['automake']['version']   = '1.14.1'
default['automake']['url']       = "http://ftp.gnu.org/gnu/automake/automake-#{node['automake']['version']}.tar.gz"
default['automake']['make_opts'] = %w{ -j2 }
