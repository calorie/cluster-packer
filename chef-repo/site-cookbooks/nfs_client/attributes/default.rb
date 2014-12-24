default['nfs']['user'] = node['user'] || 'root'
default['nfs']['mount_dir'] = node['nfs']['user'] == 'root' ? '/root/data' : File.join('/home', node['nfs']['user'], 'data')
