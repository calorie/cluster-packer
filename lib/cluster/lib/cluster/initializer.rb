require 'net/https'
require 'fileutils'
require 'yaml'
require 'erb'

class Initializer
  def initialize(configure, options = {})
    @config  = configure.env_config
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
    response = curl('https://raw.githubusercontent.com/phusion/baseimage-docker/master/image/insecure_key')
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
    packer_mpi
    packer_nfs if @config[:nfs][:dummy]
  end

  private

  def curl(url)
    uri           = URI.parse(url)
    https         = Net::HTTP.new(uri.host, uri.port)
    https.use_ssl = true
    request       = Net::HTTP::Post.new(uri.path)
    https.request(request)
  end

  def image?(repo, tag)
    images = `docker images | grep '#{repo}' | awk '{print $1 ":" $2}'`.split("\n")
    images.each do |image|
      return true if image == "#{repo}:#{tag}"
    end
    false
  end

  def packer_mpi
    repo = 'cluster/message-passing-interface'
    tag  = @config[:image_tag] || 'latest'
    return if !@options[:force] && image?(repo, tag)
    vars = "-var 'server_ip=#{@config[:nfs][:ip]}'"
    vars << " -var 'tag=#{tag}'"
    vars << " -var 'user=#{@config[:login_user]}'"
    run_packer('packer-mpi.json', vars)
  end

  def packer_nfs
    repo = 'cluster/network-file-system'
    tag  = @config[:nfs][:image_tag] || 'latest'
    return if !@options[:force] && image?(repo, tag)
    vars = "-var 'tag=#{tag}'"
    run_packer('packer-nfs.json', vars)
  end

  def run_packer(json, vars = '')
    return false unless File.exist?(json)
    system("packer build #{vars} #{json}")
  end
end
