default['nfs']['user'] = node['user'] || 'root'
default['nfs']['mount_dir'] = if node['nfs']['user'] == 'root'
                                File.join('/', 'root', 'data')
                              else
                                File.join('/', 'home', node['nfs']['user'], 'data')
                              end
