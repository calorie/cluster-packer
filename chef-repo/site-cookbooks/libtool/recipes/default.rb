#
# Cookbook Name:: libtool
# Recipe:: default
#
# Copyright 2014, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

ark 'libtool' do
  owner     node['user']
  url       node['libtool']['url']
  version   node['libtool']['version']
  make_opts node['libtool']['make_opts']
  timeout   36000
  action    :install_with_make
end
