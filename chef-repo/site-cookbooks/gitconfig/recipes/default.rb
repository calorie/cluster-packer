#
# Cookbook Name:: gitconfig
# Recipe:: default
#
# Copyright 2014, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

template '/etc/gitconfig' do
  source 'gitconfig.erb'
  owner 'root'
  mode '0755'
end
