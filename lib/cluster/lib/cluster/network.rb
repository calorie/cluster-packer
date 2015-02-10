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
      ENV['PDSH_SSH_ARGS'] ||= default_pdsh_ssh_args
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
      nfs = @config[:nfs][:dummy] ? 'nfs-dummy' : 'nfs'
      run_scripts(nfs, mpi_hashes)
    end

    private

    def default_pdsh_ssh_args
      "-i #{@insecure_key} -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no"
    end

    def run_scripts(nfs, mpi_hashes)
      remotes = mpi_hashes_to_remotes(mpi_hashes)
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
  sudo mount -t nfs -o rw,proto=tcp,port=2049 #{@config[:nfs][:ip]}:#{@data} #{@data}
fi
'
EOS
    end

    def copy_ssh_files(remotes)
      system("pdsh -R ssh -l #{@user} -w #{remotes} '#{File.join(@scripts, 'copy_ssh_files.sh')}'")
    end

    def setup_ssh(mpi_hashes)
      return setup_linking_all_hosts(mpi_hashes) if @network.nil? || @network.empty?
      hosts = mpi_hashes.map { |h| h[:host] }
      mpi_hashes.each do |r|
        return false unless setup_linking_hosts(r[:host], mpi_hashes)
      end
      true
    end

    def setup_linking_all_hosts(mpi_hashes)
      link_hosts(mpi_hashes_to_remotes(mpi_hashes))
    end

    def setup_linking_hosts(host, mpi_hashes)
      hosts = @network[host.to_sym]
      if hosts.is_a?(Array) && !hosts.empty? && !host.nil?
        hosts << host
        remotes = hosts.map do |h|
          mpi_hash = mpi_hashes.find { |m| m[:host] == h }
          mpi_hash[:ip] || mpi_hash[:host]
        end.join(',')
        return false unless link_hosts(remotes, host)
      else
        puts 'Please specify `host` in the config file.' if host.nil?
        if !hosts.is_a?(Array) || hosts.empty?
          puts 'Please specify networking hosts with Array in the config file.'
        end
        return false
      end
      true
    end

    def link_hosts(remotes, host = nil)
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

    def mpi_hashes_to_remotes(mpi_hashes)
      mpi_hashes.map { |h| h[:ip] || h[:host] }.join(',')
    end
  end
end
