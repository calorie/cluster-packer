require 'mkmf'

module Cluster
  module Validator
    module_function

    def docker?
      unless find_executable('docker')
        puts '`docker` command is not found.'
        exit 1
      end
      true
    end

    def pdsh?
      unless find_executable('pdsh')
        puts '`pdsh` command is not found.'
        exit 1
      end
      true
    end

    def vagrant?
      unless find_executable('vagrant')
        puts '`vagrant` command is not found.'
        exit 1
      end
      true
    end

    def config?
      unless File.exist?('config.yaml')
        puts 'config.yaml is not found.'
        exit 1
      end
      true
    end
  end
end
