module Cluster
  class Downer
    def initialize(configure, options = {})
      @configure = configure
      @options   = options
    end

    def down
      res = nfs
      mpi if res
    end

    def nfs
      nfs = Nfs.new(@configure, @options)
      if @options[:production]
        nfs.halt_production
      else
        nfs.halt_staging
      end
    end

    def mpi
      mpi = Mpi.new(@configure, @options)
      if @options[:production]
        mpi.halt_production
      else
        mpi.halt_staging
      end
    end
  end
end
