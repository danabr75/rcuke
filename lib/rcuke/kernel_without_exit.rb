module Rcuke
  module KernelWithoutExit
    include Kernel
    def self.exit(status)
      # Do nothing. Ignoring cucumber's exit call which would stop the script in it's tracks.
    end
  end
end