#
# Cookbook Name:: openmpi
# Recipe:: default
#
# Copyright 2014, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

node['openmpi']['packages'].each do |pkg|
  package pkg
end

if node['openmpi']['package']
  packages = node['openmpi'][node['platform_family']] || []
  packages.each { |pkg| package pkg }
else
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
end
