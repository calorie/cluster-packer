module Cluster
  class Configure
    attr_reader :config
    attr_writer :is_production

    CONFIG_FILE = 'config.yml'

    def initialize
      @config = YAML.load_file(CONFIG_FILE) if config?
      @config[:staging][:login_user]    ||= 'mpi'
      @config[:production][:login_user] ||= 'mpi'
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
      production? ? production : staging
    end

    def staging
      @config[:staging]
    end

    def production
      @config[:production]
    end

    def production?
      @is_production
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

    def home
      user = production? ? production[:login_user] : staging[:login_user]
      user == 'root' ? '/root' : File.join('/home', user)
    end

    def data
      File.join(home, 'data')
    end
  end
end
