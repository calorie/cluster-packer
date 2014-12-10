class Ssh
  def initialize(config, host, opts = [])
    @config = config.env_config
    @remote = config.production?
    @host   = host
    @ip     = ''
    @opts   = opts
  end

  def connect
    @remote ? remote : local
  end

  def local
    system("vagrant ssh #{@host} #{@opts.join(' ')}")
  end

  def remote
    @ip = if nfs?
            @config[:nfs][:ip]
          else
            n = @config[:mpi].find { |c| c[:host] == @host }
            n.nil? ? '' : n[:ip]
          end
    system("ssh #{@host}@#{@ip} #{@opts}") if valid?
  end

  private

  def nfs?
    @host == @config[:nfs][:host]
  end

  def valid?
    return true if !@ip.empty?
    puts "`#{@host}` if not found."
    false
  end
end
