require 'json'

module Cluster
  class Network
    def initialize(configure, options)
      @config  = configure.env_config
      @network = configure.network || {}
      @options = options
      @user    = @config[:login_user]
      @scripts = File.join(configure.data, 'scripts')
    end

    def up_production
      mpi = @config[:mpi]
      nfs = "#{@user}@#{@config[:nfs][:ip] || @config[:nfs][:host]}"
      remote_hashes = mpi.map do |node|
        {
          ip: node[:ip],
          host: node[:host],
        }
      end
      remotes = remote_hashes.map { |h| h[:ip] || h[:host] }.join(',')
      ENV['PDSH_SSH_ARGS'] ||= '-i insecure_key -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no'
      res = cleanup(nfs)
      res = copy_ssh_files(remotes) if res
      res = setup_ssh(remote_hashes) if res
      res ? make_hostfile(nfs) : false
    end

    def up_staging
      ids = `docker ps -q`.split("\n").join(' ')
      return false if ids.empty?
      json = `docker inspect #{ids}`
      ip_and_host_maps = JSON.parse(json).map do |j|
        next if j['Config']['Hostname'] == 'nfs-dummy'
        {
          ip: j['NetworkSettings']['IPAddress'],
          host: j['Config']['Hostname'],
        }
      end.compact
      remotes = ip_and_host_maps.map { |h| h[:ip] }.join(',')
      ENV['PDSH_SSH_ARGS'] ||= '-i insecure_key -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no'
      nfs = @config[:nfs][:dummy] ? 'nfs-dummy' : 'nfs'
      res = cleanup(nfs)
      res = copy_ssh_files(remotes) if res
      res = setup_ssh(ip_and_host_maps) if res
      res ? make_hostfile(nfs) : false
    end

    private

    def cleanup(nfs)
      cleanup_sh = File.join(@scripts, 'cleanup.sh')
      if @options[:production]
        system("ssh #{nfs} -i insecure_key '#{cleanup_sh}'")
      else
        system("vagrant ssh #{nfs} -c '#{cleanup_sh}'")
      end
    end

    def copy_ssh_files(remotes)
      system("pdsh -R ssh -l #{@user} -w #{remotes} '#{File.join(@scripts, 'copy_ssh_files.sh')}'")
    end

    def setup_ssh(ip_and_host_maps)
      hosts = ip_and_host_maps.map { |h| h[:host] }
      ip_and_host_maps.each do |r|
        return false unless setup_linking_hosts(r[:host], hosts, ip_and_host_maps)
      end
      true
    end

    def setup_linking_hosts(host, hosts, ip_and_host_maps)
      linked_hosts = @network[host.to_sym] || hosts
      if linked_hosts.is_a?(Array) && !linked_hosts.empty? && !host.nil?
        linked_hosts << host
        linked_ips_or_hosts = linked_hosts.map do |h|
          remote_hash = ip_and_host_maps.find { |m| m[:host] == h }
          remote_hash[:ip] || remote_hash[:host]
        end
        return false unless link_hosts(host, linked_ips_or_hosts.join(','))
      else
        puts 'Please specify `host` in the config file.' if host.nil?
        if !linked_hosts.is_a?(Array) || linked_hosts.empty?
          puts 'Please specify networking hosts with Array in the config file.'
        end
        return false
      end
      true
    end

    def link_hosts(host, remotes)
      system("pdsh -R ssh -l #{@user} -w #{remotes} '#{File.join(@scripts, 'setup_ssh.sh')} #{host}'")
    end

    def make_hostfile(nfs)
      make_hostfile_sh = File.join(@scripts, 'make_hostfile.sh')
      if @options[:production]
        system("ssh #{nfs} -i insecure_key '#{make_hostfile_sh}'")
      else
        system("vagrant ssh #{nfs} -c '#{make_hostfile_sh}'")
      end
    end
  end
end
