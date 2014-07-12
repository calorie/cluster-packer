class Nfs
  def initialize(config, options)
    @config  = config
    @options = options
  end

  def up_production
    nfs  = @config[:nfs]
    user = @config[:login_user]
    host = nfs[:ip] || nfs[:host]
    system("cd chef-repo && bundle exec knife solo bootstrap #{user}@#{host} nodes/nfs.json && cd ..")
  end

  def up_staging
    system('vagrant up nfs --provider=virtualbox')
  end

  def halt_production
    nfs = "#{@config[:login_user]}@#{@config[:nfs][:ip] || @config[:nfs][:host]}"
    system("ssh #{nfs} 'sudo shutdown -h now'")
  end

  def halt_staging
    system('vagrant halt nfs')
  end
end
