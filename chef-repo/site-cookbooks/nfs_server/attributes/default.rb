default['nfs']['user']       = node['user'] || 'root'
default['nfs']['user_home']  = if node['nfs']['user'] == 'root'
                                 File.join('/', 'root')
                               else
                                 File.join('/', 'home', node['nfs']['user'])
                               end
default['nfs']['mount_dir']  = File.join(node['nfs']['user_home'], 'data')
