require 'json'

module Cluster
  class Network
    def initialize(configure, options)
      @config       = configure.env_config
      @network      = configure.network || {}
      @data         = configure.data
      @insecure_key = configure.key_path
      @user         = @config[:login_user]
      @scripts      = File.join(@data, 'scripts')
      @options      = options
    end

    def up_production
      mpi = @config[:mpi]
      nfs = "#{@user}@#{@config[:nfs][:ip] || @config[:nfs][:host]}"
      mpi_hashes = mpi.map do |node|
        {
          ip: node[:ip],
          host: node[:host],
        }
      end
      ENV['PDSH_SSH_ARGS'] ||= "-i #{@insecure_key} -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no"
      run_scripts(nfs, mpi_hashes)
    end

    def up_staging
      ids = `docker ps -q`.split("\n").join(' ')
      return false if ids.empty?
      json = `docker inspect #{ids}`
      mpi_hashes = JSON.parse(json).map do |j|
        next if j['Config']['Hostname'] == 'nfs-dummy'
        {
          ip: j['NetworkSettings']['IPAddress'],
          host: j['Config']['Hostname'],
        }
      end.compact
      ENV['PDSH_SSH_ARGS'] ||= "-i #{@insecure_key} -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no"
      nfs = @config[:nfs][:dummy] ? 'nfs-dummy' : 'nfs'
      run_scripts(nfs, mpi_hashes)
    end

    private

    def run_scripts(nfs, mpi_hashes)
      remotes = mpi_hashes.map { |h| h[:ip] || h[:host] }.join(',')
      r = cleanup(nfs)
      r = mount(remotes)          if r
      r = copy_ssh_files(remotes) if r
      r = setup_ssh(mpi_hashes)   if r
      r ? make_hostfile(nfs) : false
    end

    def cleanup(nfs)
      cleanup_sh = File.join(@scripts, 'cleanup.sh')
      if @options[:production]
        system("ssh #{nfs} -i #{@insecure_key} '#{cleanup_sh}'")
      else
        system("vagrant ssh #{nfs} -c '#{cleanup_sh}' -- -l #{@user} -i #{@insecure_key}")
      end
    end

    def mount(remotes)
      system <<-EOS
pdsh -R ssh -l #{@user} -w #{remotes} '
if ! mountpoint -q #{@data} ; then
  sudo rpcbind start
  sudo mount -t nfs -o rw,proto=tcp,port=2049 #{@config[:nfs][:ip]}:#{@data} #{@data}
fi
'
EOS
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
        system("ssh #{nfs} -i #{@insecure_key} '#{make_hostfile_sh}'")
      else
        system("vagrant ssh #{nfs} -c '#{make_hostfile_sh}' -- -l #{@user} -i #{@insecure_key}")
      end
    end
  end
end
