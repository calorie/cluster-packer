require 'yaml'
require 'erb'

module Cluster
  class Configure
    attr_reader :config

    CONFIG_FILE  = 'config.yml'
    KEY_FILE     = 'insecure_key'
    CHEF_REPO    = 'chef-repo'
    VAGRANT_FILE = 'Vagrantfile'
    PACKER_NFS   = 'packer-nfs.json'
    PACKER_MPI   = 'packer-mpi.json'

    def initialize(production = false)
      @production = production
      @root       = Dir.pwd
      config      = YAML.load_file(config_path) if config?
      @config     = default.deep_merge(config)
    end

    def root_path
      @root
    end

    def config_path
      File.join(@root, CONFIG_FILE)
    end

    def key_path
      File.join(@root, KEY_FILE)
    end

    def chef_repo
      File.join(@root, CHEF_REPO)
    end

    def vagrant_file
      File.join(@root, VAGRANT_FILE)
    end

    def packer_nfs
      File.join(@root, PACKER_NFS)
    end

    def packer_mpi
      File.join(@root, PACKER_MPI)
    end

    def env_config
      production? ? production : staging
    end

    def staging
      @config[:staging]
    end

    def production
      @config[:production]
    end

    def production?
      @production
    end

    def deploy
      @config[:deploy]
    end

    def network
      @config[:network]
    end

    def dummy?
      production? ? false : staging[:nfs][:dummy]
    end

    def home
      user = production? ? production[:login_user] : staging[:login_user]
      user == 'root' ? '/root' : File.join('/home', user)
    end

    def data
      File.join(home, 'data')
    end

    def default
      {
        staging: {
          node_num: 1,
          login_user: 'mpi',
          nfs: {
            dummy: true,
          },
        },
        production: {
          login_user: 'mpi',
          mpi: [],
        },
        deploy: {
          ssh_opts: '',
          test: true,
        },
      }
    end

    private

    def config?
      return true if File.exist?(config_path) || example?
      puts "#{config_path} is not found."
      exit 1
    end

    def example?
      while true
        print "Would you like to use #{CONFIG_FILE}.example? [y|n]:"
        case STDIN.gets
        when /\A[yY]/
          example
          return true
        when /\A[nN]/
          return false
        end
      end
    end

    def example
      templates = File.join(File.dirname(__FILE__), 'templates')
      template = File.join(templates, "#{CONFIG_FILE}.example")
      unless File.exist?(template)
        puts "#{template} is not found."
        exit 1
      end
      erb = ERB.new(File.read(template))
      File.write(config_path, erb.result)
    end
  end
end
