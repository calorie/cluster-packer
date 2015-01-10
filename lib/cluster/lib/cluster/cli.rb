require 'thor'

module Cluster
  class Cli < Thor
    include Cluster::Base

    class_option :production, type: :boolean, default: false, aliases: '-p', banner: 'Flag of production'

    desc 'init', 'Initialize cluster'
    method_option :force,     type: :boolean, aliases: '-f', banner: 'Force flag'
    method_option :key,       type: :boolean, aliases: '-k', banner: 'Download insecure_key'
    method_option :cookbooks, type: :boolean, aliases: '-c', banner: 'Download cookbooks'
    method_option :vagrant,   type: :boolean, aliases: '-v', banner: 'Create Vagrantfile'
    method_option :image,     type: :boolean, aliases: '-i', banner: 'Create images of containers'
    def init
      @@configure.is_production = options[:production]
      i = Initializer.new(@@configure, options)
      if init_all?(options)
        i.bootstrap
      else
        i.insecure_key if options[:key]
        i.cookbooks    if options[:cookbooks]
        i.vagrantfile  if options[:vagrant]
        i.packer       if options[:image]
      end
    end

    desc 'up', 'Boot cluster'
    method_option :nfs,        type: :boolean, aliases: '-n', banner: 'Boot NFS node'
    method_option :mpi,        type: :boolean, aliases: '-m', banner: 'Boot MPI nodes'
    method_option :connection, type: :boolean, aliases: '-c', banner: 'Setup connection'
    def up
      @@configure.is_production = options[:production]
      u = Upper.new(@@configure, options)
      if up_all?(options)
        u.up
      else
        u.nfs     if options[:nfs]
        u.mpi     if options[:mpi]
        u.network if options[:connection]
      end
    end

    desc 'halt', 'Halt cluster'
    method_option :nfs, type: :boolean, aliases: '-n', banner: 'Halt NFS node'
    method_option :mpi, type: :boolean, aliases: '-m', banner: 'Halt MPI nodes'
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

    desc 'deploy [PROJECT_PATH]', 'Deploy project'
    method_option :staging, type: :boolean, aliases: '-s', banner: 'Deploy to staging'
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

    before_method(*instance_methods(false)) do
      docker?
      pdsh?
      vagrant?
      packer?
      @@configure = Configure.new
    end

    private

    def init_all?(options)
      !options[:key] && !options[:vagrant] && !options[:cookbooks] && !options[:image]
    end

    def up_all?(options)
      !options[:nfs] && !options[:mpi] && !options[:connection]
    end

    def down_all?(options)
      !options[:nfs] && !options[:mpi]
    end
  end
end
