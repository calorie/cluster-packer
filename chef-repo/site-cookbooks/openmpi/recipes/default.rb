#
# Cookbook Name:: openmpi
# Recipe:: default
#
# Copyright 2014, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

if node['openmpi']['package']
  packages = node['openmpi'][node['platform_family']] || []
  packages.each { |pkg| package pkg }
else
  node['openmpi']['packages'].each do |pkg|
    package pkg
  end

  ark 'openmpi' do
    owner     node['user']
    url       node['openmpi']['url']
    version   node['openmpi']['version']
    make_opts node['openmpi']['make_opts']
    timeout   36000
    action    :install_with_make
  end
end
