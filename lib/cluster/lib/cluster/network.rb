require 'json'

class Network
  def initialize(config, options)
    @config  = config
    @options = options
    @user    = @config[:login_user]
    @home    = @user == 'root' ? '/root' : File.join('/home', @user)
  end

  def up_production
    mpi     = @config[:mpi]
    nfs     = "#{@user}@#{@config[:nfs][:ip] || @config[:nfs][:host]}"
    remotes = mpi.map { |node| node[:ip] || node[:host] }.join(',')
    ENV['PDSH_SSH_ARGS'] ||= '-o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no'
    res = cleanup(nfs)
    res = copy_ssh_files(remotes) if res
    res = setup_ssh(remotes) if res
    res ? make_hostfile(nfs) : false
  end

  def up_staging
    ids = `docker ps -q`.split("\n").join(' ')
    return false if ids.empty?
    json    = `docker inspect #{ids}`
    remotes = JSON.parse(json).map { |j| j['NetworkSettings']['IPAddress'] }.join(',')
    ENV['PDSH_SSH_ARGS'] ||= '-i insecure_key -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no'
    res = cleanup
    res = copy_ssh_files(remotes) if res
    res = setup_ssh(remotes) if res
    res ? make_hostfile : false
  end

  private

  def cleanup(nfs = nil)
    if @options[:production]
      if nfs.nil?
        false
      else
        system("ssh #{nfs} 'sudo /data/scripts/cleanup.sh'")
      end
    else
      system("vagrant ssh nfs -c 'echo vagrant | sudo -S /data/scripts/cleanup.sh'")
    end
  end

  def copy_ssh_files(remotes)
    system("pdsh -R ssh -l #{@user} -w #{remotes} 'sudo #{@home}/copy_ssh_files.sh'")
  end

  def setup_ssh(remotes)
    system("pdsh -R ssh -l #{@user} -w #{remotes} 'sudo #{@home}/setup_ssh.sh'")
  end

  def make_hostfile(nfs = nil)
    if @options[:production]
      if nfs.nil?
        false
      else
        system("ssh #{nfs} 'sudo /data/scripts/make_hostfile.sh'")
      end
    else
      system("vagrant ssh nfs -c 'echo vagrant | sudo -S /data/scripts/make_hostfile.sh'")
    end
  end
end
