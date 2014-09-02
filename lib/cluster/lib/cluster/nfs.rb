class Nfs
  def initialize(configure, options)
    @config  = configure.env_config
    @options = options
  end

  def up_production
    nfs  = @config[:nfs]
    user = @config[:login_user]
    host = nfs[:ip] || nfs[:host]
    system("cd chef-repo && bundle exec knife solo bootstrap #{user}@#{host} nodes/nfs.json && cd ..")
  end

  def up_staging
    system(vagrant_up)
  end

  def halt_production
    nfs = "#{@config[:login_user]}@#{@config[:nfs][:ip] || @config[:nfs][:host]}"
    system("ssh #{nfs} 'sudo shutdown -h now'")
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
