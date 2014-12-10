require 'fileutils'

module Cluster
  class Deployer
    def initialize(project, configure, options = {})
      @staging    = configure.staging
      @production = configure.production
      @deploy     = configure.deploy
      @project    = File.expand_path(@deploy[:repository] || project)
      @options    = options
    end

    def deploy
      exit 1 unless valid_project?(@project)
      deploy_staging
      deploy_production if test_passed? && !@options[:staging]
    end

    def deploy_staging
      case @deploy[:protcol]
      when 'scp'
        scp_deploy
      when 'git'
        git_deploy
      end
    end

    def deploy_production
      case @deploy[:protcol]
      when 'scp'
        scp_deploy(true)
      when 'git'
        git_deploy(true)
      end
    end

    def test_passed?
      remote = deploy_node(@staging)
      path   = @deploy[:path]
      system("ssh -i ./insecure_key #{remote} 'cd #{path} && #{@deploy[:test_cmd]}'")
      results_dir = './.cluster'
      FileUtils.mkdir(results_dir) unless File.exist?(results_dir)
      FileUtils.rm_f(File.join(results_dir, '*'))
      system("scp -i ./insecure_key #{remote}:#{File.join(path, 'rank*_output.xml')} #{results_dir}")
      XmlParser.parse(results_dir)
    end

    private

    def scp_deploy(production = false)
      config   = production ? @production : @staging
      remote   = deploy_node(config, production)
      ssh_opts = ssh_options(production)
      now      = Time.now.strftime('%Y%m%d%H%M%S')
      path     = @deploy[:path]
      repo     = "#{path}-#{now}"
      system("scp -r #{ssh_opts} #{@project} #{remote}:#{repo}")
      system("ssh #{ssh_opts} #{remote} 'rm -f #{path} && ln -s #{repo} #{path}'")
    end

    def git_deploy(production = false)
      config     = production ? @production : @staging
      remote     = deploy_node(config, production)
      path       = @deploy[:path]
      repository = @deploy[:repository]
      ssh_opts   = ssh_options(production)
      system <<-EOS
ssh #{ssh_opts} #{remote} '
if [ -d #{File.join(path, '.git')} ]; then
  cd #{path}
  git pull
else
  git clone #{repository} #{path}
fi
'
EOS
    end

    def deploy_node(config, production = false)
      if production
        mpi    = config[:mpi].first
        remote = mpi[:ip] || mpi[:host]
      else
        id     = `docker ps -q`.split("\n").first
        json   = `docker inspect #{id}`
        remote = JSON.parse(json).first['NetworkSettings']['IPAddress']
      end
      "#{config[:login_user]}@#{remote}"
    end

    def ssh_options(production = false)
      ssh_opts = @deploy[:ssh_opts] || ''
      ssh_opts << ' -i ./insecure_key' unless production
      ssh_opts
    end

    def valid_project?(project)
      return true if @deploy[:protcol] == 'git'
      src  = File.join(project, 'src')
      spec = File.join(project, 'spec')
      main = File.join(spec, 'main_spec.c')
      [src, spec, main].each do |path|
        unless File.exist?(path)
          puts "#{path} is not found."
          return false
        end
      end
      true
    end
  end
end
