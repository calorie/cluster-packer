#
# Cookbook Name:: nfs_server
# Recipe:: default
#
# Copyright 2014, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

include_recipe 'nfs::server'

mount_dir = node['nfs']['mount_dir']
scripts_dir = File.join(mount_dir, 'scripts')

directory scripts_dir do
  recursive true
end

%w{
  cleanup.sh
  make_hostfile.sh
}.each do |script|
  template File.join(scripts_dir, script) do
    mode 755
    variables(mount_dir: mount_dir)
  end
end

nfs_export mount_dir do
  network   '*'
  writeable true
  sync      true
  options   %w{ rw insecure no_root_squash no_subtree_check sync fsid=0 }
end
