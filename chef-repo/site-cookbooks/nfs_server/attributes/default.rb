default['nfs']['user']       = node['user'] || 'root'
default['nfs']['user_home']  = node['nfs']['user'] == 'root' ? '/root' : File.join('/home', node['nfs']['user'])
default['nfs']['mount_dir']  = File.join(node['nfs']['user_home'], 'data')
default['nfs']['server_ip']  = '192.168.33.10'
