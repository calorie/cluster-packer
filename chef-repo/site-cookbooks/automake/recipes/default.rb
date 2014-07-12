#
# Cookbook Name:: automake
# Recipe:: default
#
# Copyright 2014, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

include_recipe 'autoconf'

ark 'automake' do
  owner     node['user']
  url       node['automake']['url']
  version   node['automake']['version']
  make_opts node['automake']['make_opts']
  timeout   36000
  action    :install_with_make
end
