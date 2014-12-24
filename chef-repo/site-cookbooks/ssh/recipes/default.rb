#
# Cookbook Name:: ssh
# Recipe:: default
#
# Copyright 2014, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

ruby_block 'ssh global config' do
  block do
    f = Chef::Util::FileEdit.new('/etc/ssh/ssh_config')
    f.insert_line_if_no_match('/\AStrictHostKeyChecking no\z', 'StrictHostKeyChecking no')
    f.write_file
  end
end
