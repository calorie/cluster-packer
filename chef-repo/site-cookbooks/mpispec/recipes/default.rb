#
# Cookbook Name:: mpispec
# Recipe:: default
#
# Copyright 2014, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

%w{
  libtool
  automake
  autoconf
  binutils
}.each { |pkg| package pkg }

ark 'mpispec' do
  owner       node['user']
  url         node['mpispec']['url']
  version     node['mpispec']['revision']
  extension   'tar.gz'
  environment node['mpispec']['environment']
  make_opts   node['mpispec']['make_opts']
  timeout     36000
  action      :install_with_make
end
