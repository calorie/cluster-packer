#
# Cookbook Name:: nfs_client
# Recipe:: default
#
# Copyright 2014, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

include_recipe 'nfs'

directory node['nfs']['mount_dir'] do
  owner node['nfs']['user']
  group node['nfs']['user']
end
