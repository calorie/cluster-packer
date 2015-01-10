#
# Cookbook Name:: mpispec
# Recipe:: default
#
# Copyright 2014-2015, Yuu Shigetani
#
# MIT License.
#

node['mpispec']['dependencies'].each { |pkg| package pkg }

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
