#
# Cookbook Name:: nfs_client
# Recipe:: default
#
# Copyright 2014-2015, Yuu Shigetani
#
# MIT License.
#

include_recipe 'nfs'

directory node['nfs']['mount_dir'] do
  owner node['nfs']['user']
  group node['nfs']['user']
end
