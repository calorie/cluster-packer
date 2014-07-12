#
# Cookbook Name:: nfs_client
# Recipe:: default
#
# Copyright 2014, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

include_recipe 'nfs'

server_dir = node['nfs']['server_dir']
mount_dir  = node['nfs']['mount_dir']
server_ip  = node['nfs']['server_ip']

directory mount_dir

# mount mount_dir do
#   device  "#{server_ip}:#{server_dir}"
#   fstype  'nfs'
#   options 'rw,proto=tcp,port=2049'
#   action  [:mount, :enable]
# end
