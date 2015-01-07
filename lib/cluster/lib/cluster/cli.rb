require 'thor'

module Cluster
  class Cli < Thor
    include Cluster::Base

    class_option :production, type: :boolean, default: false, aliases: '-p', banner: 'Flag of production'

    desc 'init', 'Initialize cluster'
    method_option :force,     type: :boolean, aliases: '-f', banner: 'Force create'
    method_option :key,       type: :boolean, aliases: '-k', banner: 'Init insecure_key'
    method_option :cookbooks, type: :boolean, aliases: '-c', banner: 'Init Cookbooks'
    method_option :vagrant,   type: :boolean, aliases: '-v', banner: 'Init Vagrantfile'
    method_option :packer,    type: :boolean, aliases: '-P', banner: 'Create MPI node image'
    def init
      @@configure.is_production = options[:production]
      i = Initializer.new(@@configure, options)
      if init_all?(options)
        i.bootstrap
      else
        i.insecure_key if options[:key]
        i.cookbooks    if options[:cookbooks]
        i.vagrantfile  if options[:vagrant]
        i.packer       if options[:packer]
      end
    end

    desc 'up', 'Up cluster'
    method_option :nfs,     type: :boolean, aliases: '-n', banner: 'Up nfs VM'
    method_option :mpi,     type: :boolean, aliases: '-m', banner: 'Up mpi containers'
    method_option :network, type: :boolean, aliases: '-N', banner: 'Setup network'
    def up
      @@configure.is_production = options[:production]
      u = Upper.new(@@configure, options)
      if up_all?(options)
        u.up
      else
        u.nfs     if options[:nfs]
        u.mpi     if options[:mpi]
        u.network if options[:network]
      end
    end

    desc 'halt', 'Halt cluster'
    method_option :nfs, type: :boolean, aliases: '-n', banner: 'Halt nfs VM'
    method_option :mpi, type: :boolean, aliases: '-m', banner: 'Halt mpi containers'
    def halt
      @@configure.is_production = options[:production]
      d = Downer.new(@@configure, options)
      if down_all?(options)
        d.down
      else
        d.nfs if options[:nfs]
        d.mpi if options[:mpi]
      end
    end

    desc 'deploy [PROJECT_PATH]', 'deploy project'
    method_option :staging, type: :boolean, aliases: '-s', banner: 'Deploy to staging'
    def deploy(project = '.')
      d = Deployer.new(project, @@configure, options)
      d.deploy
    end

    desc 'ssh [HOST_NAME] [OPTIONS]', 'connect to the host'
    def ssh(host, *opts)
      @@configure.is_production = options[:production]
      ssh = Ssh.new(@@configure, host, opts)
      ssh.connect
    end

    before_method(*instance_methods(false)) do
      docker?
      pdsh?
      vagrant?
      packer?
      @@configure = Configure.new
    end

    private

    def init_all?(options)
      !options[:key] && !options[:vagrant] && !options[:cookbooks] && !options[:packer]
    end

    def up_all?(options)
      !options[:nfs] && !options[:mpi] && !options[:network]
    end

    def down_all?(options)
      !options[:nfs] && !options[:mpi]
    end
  end
end
