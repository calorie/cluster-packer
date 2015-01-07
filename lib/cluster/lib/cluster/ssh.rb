module Cluster
  class Ssh
    def initialize(config, host, opts = [])
      @config = config.env_config
      @remote = config.production?
      @host   = host
      @opts   = opts.join(' ')
    end

    def connect
      @remote ? remote : local
    end

    def local
      system("vagrant ssh #{@host} #{@opts}")
    end

    def remote
      user = @config[:login_user]
      ip = if nfs?
             @config[:nfs][:ip]
           else
             n = @config[:mpi].find { |c| c[:host] == @host }
             n.nil? ? '' : n[:ip]
           end
      target = ip.nil? ? @host : ip.empty? ? nil : "#{user}@#{ip}"
      return system("ssh #{target} #{@opts} -i insecure_key") unless target.nil?
      puts "`#{@host}` is not found."
      false
    end

    private

    def nfs?
      @host == @config[:nfs][:host]
    end
  end
end
