require 'mkmf'

module Cluster
  module Validator
    module_function

    def docker?
      command?('docker')
    end

    def pdsh?
      command?('pdsh')
    end

    def vagrant?
      command?('vagrant')
    end

    def packer?
      command?('packer')
    end

    def chef_solo?
      command?('chef-solo')
    end

    def check_requirements
      docker?
      pdsh?
      vagrant?
      packer?
    end

    private

    def command?(command)
      unless find_executable(command)
        puts "`#{command}` command is not found."
        exit 1
      end
      true
    end
  end
end
