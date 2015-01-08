require 'json'

module Cluster
  class Nfs
    def initialize(configure, options)
      @root         = configure.root_path
      @config       = configure.env_config
      @chef_repo    = configure.chef_repo
      @insecure_key = configure.key_path
      @options      = options
    end

    def up_production
      nfs  = @config[:nfs]
      user = @config[:setup_user]
      host = nfs[:ip] || nfs[:host]
      system("cd #{@chef_repo} && bundle exec knife solo bootstrap #{user}@#{host} nodes/nfs.json && cd #{@root}")
    end

    def up_staging
      system(vagrant_up)
    end

    def halt_production
      nfs = "#{@config[:login_user]}@#{@config[:nfs][:ip] || @config[:nfs][:host]}"
      system("ssh #{nfs} -i #{@insecure_key} 'sudo shutdown -h now'")
    end

    def halt_staging
      system(vagrant_halt)
    end

    private

    def vagrant_up
      if @config[:nfs][:dummy]
        'vagrant up nfs-dummy --provider=docker'
      else
        'vagrant up nfs --provider=virtualbox'
      end
    end

    def vagrant_halt
      if @config[:nfs][:dummy]
        'vagrant destroy -f nfs-dummy'
      else
        'vagrant halt nfs'
      end
    end
  end
end
