#
# Cookbook Name:: gcc
# Recipe:: default
#
# Copyright 2014, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

package 'libmpc-dev'

ark 'gcc' do
  owner         node['user']
  url           node['gcc']['url']
  version       node['gcc']['version']
  autoconf_opts node['gcc']['autoconf_opts']
  make_opts     node['gcc']['make_opts']
  timeout       36000
  action        :install_with_make

  unless node['gcc']['environment'].empty?
    environment node['gcc']['environment']
  end
end
