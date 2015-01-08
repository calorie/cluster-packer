#
# Cookbook Name:: nfs_server
# Recipe:: default
#
# Copyright 2014, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

include_recipe 'nfs::server'

mount_dir   = node['nfs']['mount_dir']
configs_dir = File.join(mount_dir, 'configs')
keys_dir    = File.join(mount_dir, 'keys')
scripts_dir = File.join(mount_dir, 'scripts')

[mount_dir, configs_dir, keys_dir, scripts_dir].each do |d|
  directory d do
    owner node['nfs']['user']
    group node['nfs']['user']
  end
end

%w{
  cleanup.sh
  make_hostfile.sh
  copy_ssh_files.sh
  setup_ssh.sh
}.each do |script|
  template File.join(scripts_dir, script) do
    owner node['nfs']['user']
    group node['nfs']['user']
    mode '0755'
    variables(
      user:      node['nfs']['user'],
      user_home: node['nfs']['user_home'],
      mount_dir: mount_dir
    )
  end
end

nfs_export mount_dir do
  network   '*'
  writeable true
  sync      true
  options   %w(rw insecure no_root_squash no_subtree_check sync fsid=0)
end
