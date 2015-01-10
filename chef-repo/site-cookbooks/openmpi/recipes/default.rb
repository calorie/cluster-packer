#
# Cookbook Name:: openmpi
# Recipe:: default
#
# Copyright 2014-2015, Yuu Shigetani
#
# MIT License.
#

include_recipe 'build-essential'

if node['openmpi']['compile']
  node['openmpi']['dependencies'].each { |pkg| package pkg }

  ark 'openmpi' do
    owner         node['user']
    url           node['openmpi']['url']
    version       node['openmpi']['version']
    autoconf_opts node['openmpi']['conf_opts']
    make_opts     node['openmpi']['make_opts']
    timeout       36000
    action        :install_with_make
  end

  execute 'ldconfig'
else
  packages = node['openmpi'][node['platform_family']] || []
  packages.each { |pkg| package pkg }
end
