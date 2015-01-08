require 'fileutils'

module Cluster
  class Mpi
    def initialize(configure, options)
      @root         = configure.root_path
      @config       = configure.env_config
      @chef_repo    = configure.chef_repo
      @insecure_key = configure.key_path
      @options      = options
    end

    def up_production
      mpi = @config[:mpi]
      remotes = mpi.map do |node|
        user = @config[:setup_user]
        host = node[:ip] || node[:host]
        create_json(user, host)
        "#{user}@#{host}"
      end
      system("cd #{@chef_repo} && (echo #{remotes.join(' ')} | xargs -P #{remotes.count} -n 1 bundle exec knife solo bootstrap) && cd #{@root}")
    end

    def up_staging
      nodes = (0...@config[:node_num]).map { |i| "mpi#{i}" }.join(' ')
      system("vagrant up #{nodes} --provider=docker")
    end

    def halt_production
      mpi     = @config[:mpi]
      user    = @config[:login_user]
      remotes = mpi.map { |node| node[:ip] || node[:host] }.join(',')
      system("pdsh -R ssh -l #{user} -w #{remotes} -i #{@insecure_key} 'sudo shutdown -h now'")
    end

    def halt_staging
      nodes = (0...@config[:node_num]).map { |i| "mpi#{i}" }.join(' ')
      system("vagrant destroy -f #{nodes}") unless nodes.empty?
    end

    private

    def create_json(user, host)
      nodes_dir = File.join(@chef_repo, 'nodes')
      host_json = File.join(nodes_dir, "#{host}.json")
      return true if File.exist?(host_json) && host != 'mpi'

      mpi_json = File.join(nodes_dir, 'mpi.json')
      unless File.exist?(mpi_json)
        puts "#{mpi_json} is not found."
        exit 1
      end
      FileUtils.cp(mpi_json, host_json)
    end
  end
end
