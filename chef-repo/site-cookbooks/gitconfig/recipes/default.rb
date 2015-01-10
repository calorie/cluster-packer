#
# Cookbook Name:: gitconfig
# Recipe:: default
#
# Copyright 2014-2015, Yuu Shigetani
#
# MIT License.
#

template '/etc/gitconfig' do
  source 'gitconfig.erb'
  owner 'root'
  mode '0755'
end
