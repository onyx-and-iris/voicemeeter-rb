require_relative "iremote"
require_relative "kinds"

module Voicemeeter
  module Bus
    class Bus < IRemote
      def self.make(remote, i)
        "
        Factory function for Bus classes.

        Returns a PhysicalBus or VirtualBus class
        "
        p_out, v_out = remote.kind.outs
        i < p_out ? PhysicalBus.new(remote, i) : VirtualBus.new(remote, i)
      end
    end

    class PhysicalBus < Bus
    end

    class VirtualBus < Bus
    end
  end
end
