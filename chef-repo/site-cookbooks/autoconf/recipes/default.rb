#
# Cookbook Name:: autoconf
# Recipe:: default
#
# Copyright 2014, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

ark 'autoconf' do
  owner     node['user']
  url       node['autoconf']['url']
  version   node['autoconf']['version']
  make_opts node['autoconf']['make_opts']
  timeout   36000
  action    :install_with_make
end
