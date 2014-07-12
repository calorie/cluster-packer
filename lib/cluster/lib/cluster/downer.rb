class Downer
  def initialize(config, options = {})
    @config  = config
    @options = options
  end

  def down
    res = nfs
    mpi if res
  end

  def nfs
    nfs = Nfs.new(@config, @options)
    if @options[:production]
      nfs.halt_production
    else
      nfs.halt_staging
    end
  end

  def mpi
    mpi = Mpi.new(@config, @options)
    if @options[:production]
      mpi.halt_production
    else
      mpi.halt_staging
    end
  end
end
