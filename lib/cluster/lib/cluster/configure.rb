class Configure
  attr_reader :config
  attr_writer :production

  CONFIG_FILE = 'config.yml'

  def initialize(production = false)
    @config     = YAML.load_file(CONFIG_FILE) if config?
    @production = production
  end

  def config?
    return true if File.exist?(CONFIG_FILE) || example?
    puts "#{CONFIG_FILE} is not found."
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
    File.write(CONFIG_FILE, erb.result)
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
