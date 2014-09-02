class Configure
  attr_reader :config
  attr_writer :production

  CONFIG_FILE = 'config.yaml'

  def initialize(production = false)
    @config     = YAML.load_file(CONFIG_FILE) if config?
    @production = production
  end

  def config?
    unless File.exist?(CONFIG_FILE)
      puts "#{CONFIG_FILE} is not found."
      exit 1
    end
    true
  end

  def env_config
    @production ? production : staging
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
end
