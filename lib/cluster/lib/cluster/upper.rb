module Cluster
  class Upper
    def initialize(configure, options = {})
      @configure  = configure
      @options = options
    end

    def up
      res = nfs
      res = mpi if res
      network if res
    end

    def nfs
      nfs = Nfs.new(@configure, @options)
      if @options[:production]
        nfs.up_production
      else
        nfs.up_staging
      end
    end

    def mpi
      mpi = Mpi.new(@configure, @options)
      if @options[:production]
        mpi.up_production
      else
        mpi.up_staging
      end
    end

    def network
      network = Network.new(@configure, @options)
      if @options[:production]
        network.up_production
      else
        network.up_staging
      end
    end
  end
end
