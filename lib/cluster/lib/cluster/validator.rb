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

    def config?
      unless File.exist?('config.yaml')
        puts 'config.yaml is not found.'
        exit 1
      end
      true
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
