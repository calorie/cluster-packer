require 'thor'

module Cluster
  class Cli < Thor
    include Cluster::Base

    class_option :production, type: :boolean, default: false, aliases: '-p', banner: 'Flag of production'

    desc 'init', 'Initialize cluster'
    method_option :force,     type: :boolean, aliases: '-f', banner: 'Force flag'
    method_option :local,     type: :boolean, aliases: '-l', banner: 'Install requirements'
    method_option :key,       type: :boolean, aliases: '-k', banner: 'Download insecure_key'
    method_option :cookbooks, type: :boolean, aliases: '-c', banner: 'Download cookbooks'
    method_option :vagrant,   type: :boolean, aliases: '-v', banner: 'Create Vagrantfile'
    method_option :image,     type: :boolean, aliases: '-i', banner: 'Create images of containers'
    def init
      @@configure.is_production = options[:production]
      i = Initializer.new(@@configure, options)
      return i.bootstrap if init_all?(options)
      i.local_env    if options[:local]
      i.insecure_key if options[:key]
      i.cookbooks    if options[:cookbooks]
      i.vagrantfile  if options[:vagrant]
      i.packer       if options[:image]
    end

    desc 'up', 'Boot cluster'
    method_option :nfs,        type: :boolean, aliases: '-n', banner: 'Boot NFS node'
    method_option :mpi,        type: :boolean, aliases: '-m', banner: 'Boot MPI nodes'
    method_option :connection, type: :boolean, aliases: '-c', banner: 'Setup connection'
    def up
      invoke(:init, [], vagrant: true, force: true)
      @@configure.is_production = options[:production]
      u = Upper.new(@@configure, options)
      return u.up if up_all?(options)
      u.nfs     if options[:nfs]
      u.mpi     if options[:mpi]
      u.network if options[:connection]
    end

    desc 'halt', 'Halt cluster'
    method_option :nfs, type: :boolean, aliases: '-n', banner: 'Halt NFS node'
    method_option :mpi, type: :boolean, aliases: '-m', banner: 'Halt MPI nodes'
    def halt
      @@configure.is_production = options[:production]
      d = Downer.new(@@configure, options)
      return d.down if down_all?(options)
      d.nfs if options[:nfs]
      d.mpi if options[:mpi]
    end

    desc 'deploy [PROJECT_PATH]', 'Deploy project'
    method_option :staging, type: :boolean, aliases: '-s', banner: 'Deploy to staging'
    method_option :test,    type: :boolean, aliases: '-t', banner: 'Execute tests', default: true
    def deploy(project = '.')
      d = Deployer.new(project, @@configure, options)
      d.deploy
    end

    desc 'ssh [HOST_NAME] [OPTIONS]', 'Connect to the host'
    def ssh(host, *opts)
      @@configure.is_production = options[:production]
      ssh = Ssh.new(@@configure, host, opts)
      ssh.connect
    end

    before_method(*instance_methods(false)) do |n|
      @@configure = Configure.new
    end

    before_method(*(instance_methods(false) - %i(init))) do
      docker?
      pdsh?
      vagrant?
      packer?
    end

    private

    def init_all?(options)
      options?(options, %i(key vagrant cookbooks image local))
    end

    def up_all?(options)
      options?(options, %i(nfs mpi connection))
    end

    def down_all?(options)
      options?(options, %i(nfs mpi))
    end

    def options?(options, keys)
      keys.each { |key| return false if options[key] }
      true
    end
  end
end
