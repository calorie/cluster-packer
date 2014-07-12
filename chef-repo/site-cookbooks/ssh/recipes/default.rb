#
# Cookbook Name:: ssh
# Recipe:: default
#
# Copyright 2014, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

user_home   = node['user'] == 'root' ? '/root' : File.join('/home', node['user'])
ssh_home    = File.join(user_home, '.ssh')
private_key = File.join(ssh_home, 'id_rsa')

execute 'ssh keygen' do
  command "ssh-keygen -f #{private_key} -t rsa -N '' > /dev/null"
  creates private_key
  user    node['user']
  group   node['user']
end

ruby_block 'ssh global config' do
  block do
    f = Chef::Util::FileEdit.new('/etc/ssh/ssh_config')
    f.insert_line_if_no_match('/\AStrictHostKeyChecking no\z', 'StrictHostKeyChecking no')
    f.write_file
  end
end

%w{
  copy_ssh_files.sh
  setup_ssh.sh
}.each do |script|
  template File.join(user_home, script) do
    mode 755
    owner node['user']
    group node['user']
    variables(
      user:      node['user'],
      user_home: user_home,
      server_ip: node['nfs']['server_ip'],
      mount_dir: node['nfs']['mount_dir']
    )
  end
end
