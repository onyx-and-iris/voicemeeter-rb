require_relative "iremote"
require_relative "kinds"
require_relative "mixins"

module Voicemeeter
  module Bus
    class Bus < IRemote
      include Mixins::Fades
      include Mixins::Return

      attr_reader :eq, :mode

      def self.make(remote, i)
        "
        Factory function for Bus classes.

        Returns a PhysicalBus or VirtualBus class
        "
        p_out, v_out = remote.kind.outs
        i < p_out ? PhysicalBus.new(remote, i) : VirtualBus.new(remote, i)
      end

      def initialize(remote, i)
        super
        make_accessor_bool :mute, :mono, :sel, :monitor
        make_accessor_float :gain
        make_accessor_string :label

        @eq = BusEq.new(remote, i)
        @mode = BusModes.new(remote, i)
      end

      def identifier
        "bus[#{@index}]"
      end
    end

    class PhysicalBus < Bus
    end

    class VirtualBus < Bus
    end

    class BusEq < IRemote
      def initialize(remote, i)
        super
        make_accessor_bool :on, :ab
      end

      def identifier
        "bus[#{@index}].eq"
      end
    end

    class BusModes < IRemote
      def initialize(remote, i)
        super
        make_accessor_bool :normal,
                           :amix,
                           :bmix,
                           :repeat,
                           :composite,
                           :tvmix,
                           :upmix21,
                           :upmix41,
                           :upmix61,
                           :centeronly,
                           :lfeonly,
                           :rearonly
      end

      def identifier
        "bus[#{@index}].mode"
      end
    end
  end
end
