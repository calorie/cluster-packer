require 'net/https'
require 'fileutils'
require 'yaml'
require 'erb'

class Initializer
  def initialize(config, options = {})
    @config  = config
    @options = options
  end

  def bootstrap
    insecure_key
    cookbooks
    vagrantfile
    packer
  end

  def insecure_key
    insecure_key_path = 'insecure_key'
    FileUtils.rm_rf(insecure_key_path) if @options[:force]
    return if File.exist?(insecure_key_path)
    uri           = URI.parse('https://raw.githubusercontent.com/phusion/baseimage-docker/master/image/insecure_key')
    https         = Net::HTTP.new(uri.host, uri.port)
    https.use_ssl = true
    request       = Net::HTTP::Post.new(uri.path)
    response      = https.request(request)
    File.write(insecure_key_path, response.body)
    FileUtils.chmod(0600, insecure_key_path)
  end

  def cookbooks
    cookbooks_path = File.join('chef-repo', 'cookbooks')
    FileUtils.rm_rf(cookbooks_path) if @options[:force]
    unless File.exist?(cookbooks_path)
      system("bundle exec berks vendor #{cookbooks_path}")
    end
  end

  def vagrantfile
    vagrantfile_path = 'Vagrantfile'
    return if File.exist?(vagrantfile_path) && !@options[:force]

    template = File.join('template', 'Vagrantfile.erb')
    unless File.exist?(template)
      puts "#{template} is not found."
      exit 1
    end

    _config = @config
    erb     = ERB.new(File.read(template))

    File.write(vagrantfile_path, erb.result(binding))
  end

  def packer
    repo = 'cluster/message-passing-interface'
    tag  = @config[:image_tag] || 'latest'
    return if !@options[:force] && image?(repo, tag)

    json = 'packer-mpi.json'
    if File.exist?(json)
      vars = "-var 'server_ip=#{@config[:nfs][:ip]}'"
      vars << " -var 'tag=#{tag}'"
      vars << " -var 'user=#{@config[:login_user]}'"
      system("packer build #{vars} #{json}")
    end
  end

  private

  def image?(repo, tag)
    images = `docker images | grep '#{repo}' | awk '{print $1 ":" $2}'`.split("\n")
    images.each do |image|
      return true if image == "#{repo}:#{tag}"
    end
    false
  end
end
