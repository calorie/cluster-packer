require 'net/https'
require 'fileutils'
require 'yaml'
require 'erb'

module Cluster
  class Initializer
    def initialize(configure, options = {})
      @root         = configure.root_path
      @config       = configure.env_config
      @insecure_key = configure.key_path
      @chef_repo    = configure.chef_repo
      @vagrantfile  = configure.vagrant_file
      @packer_nfs   = configure.packer_nfs
      @packer_mpi   = configure.packer_mpi
      @options      = options
    end

    def bootstrap
      insecure_key
      cookbooks
      vagrantfile
      packer
    end

    def insecure_key
      FileUtils.rm_rf(@insecure_key) if @options[:force]
      return if File.exist?(@insecure_key)
      response = curl('https://raw.githubusercontent.com/phusion/baseimage-docker/master/image/insecure_key')
      File.write(@insecure_key, response.body)
      FileUtils.chmod(0600, @insecure_key)
    end

    def cookbooks
      cookbooks_path = File.join(@chef_repo, 'cookbooks')
      FileUtils.rm_rf(cookbooks_path) if @options[:force]
      unless File.exist?(cookbooks_path)
        system("bundle exec berks vendor #{cookbooks_path}")
      end
    end

    def vagrantfile
      return if File.exist?(@vagrantfile) && !@options[:force]
      templates = File.join(File.dirname(__FILE__), 'templates')
      template = File.join(templates, 'Vagrantfile.erb')
      unless File.exist?(template)
        puts "#{template} is not found."
        exit 1
      end
      _config = @config
      erb     = ERB.new(File.read(template))
      File.write(@vagrantfile, erb.result(binding))
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
      vars = " -var 'tag=#{tag}'"
      vars << " -var 'user=#{@config[:login_user]}'"
      run_packer(@packer_mpi, vars)
    end

    def packer_nfs
      repo = 'cluster/network-file-system'
      tag  = @config[:nfs][:image_tag] || 'latest'
      return if !@options[:force] && image?(repo, tag)
      vars = "-var 'tag=#{tag}'"
      vars << " -var 'user=#{@config[:login_user]}'"
      run_packer(@packer_nfs, vars)
    end

    def run_packer(json, vars = '')
      return false unless File.exist?(json)
      system("packer build #{vars} #{json}")
    end
  end
end
