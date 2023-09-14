module Voicemeeter
  module Bus
    # Base class for Bus
    class Base
      include IRemote
      include Mixins::Fades
      include Mixins::Return
      extend MetaFunctions

      attr_reader :eq, :mode, :levels, :device
      attr_accessor_bool :mute, :mono, :sel, :monitor
      attr_accessor_float :gain
      attr_accessor_string :label

      def self.make(remote, i)
        (i < remote.kind.phys_out) ? PhysicalBus.new(remote, i) : VirtualBus.new(remote, i)
      end

      def initialize(remote, i)
        super
        @eq = BusEq.new(remote, i)
        @mode = BusModes.new(remote, i)
        @levels = BusLevels.new(remote, i)
        @device = BusDevice.new(remote, i)
      end

      def identifier
        "bus[#{@index}]"
      end
    end

    # Represents a Physical Bus
    class PhysicalBus < Base; end

    # Represents a Virtual Bus
    class VirtualBus < Base; end

    class BusEq
      include IRemote
      extend MetaFunctions

      attr_accessor_bool :on, :ab

      def identifier
        "bus[#{@index}].eq"
      end
    end

    class BusModes
      include IRemote
      extend MetaFunctions

      attr_accessor_bool :normal,
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

      def identifier
        "bus[#{@index}].mode"
      end

      def get
        sleep(@remote.delay)
        %i[amix bmix repeat composite tvmix upmix21 upmix41 upmix61 centeronly lfeonly rearonly].each do |mode|
          if send(mode)
            return mode
          end
        end
        :normal
      end
    end
  end

  class BusLevels
    include IRemote

    def initialize(remote, i)
      super
      @init = i * 8
      @offset = 8
    end

    def identifier
      "bus[#{@index}]"
    end

    def getter(mode)
      convert = ->(x) { (x > 0) ? (20 * Math.log(x, 10)).round(1) : -200.0 }

      vals = if @remote.running? && @remote.event.ldirty
        @remote.cache[:bus_level][@init, @offset]
      else
        (@init...@init + @offset).map { |i| @remote.get_level(mode, i) }
      end
      vals.map(&convert)
    end

    def all
      getter(Mixins::LevelEnum::BUS)
    end

    def isdirty? = @remote.cache[:bus_comp][@init, @offset].any?
  end

  class BusDevice
    include IRemote
    extend MetaFunctions

    attr_reader_int :sr
    attr_reader_string :name
    attr_writer_string :wdm, :ks, :mme, :asio

    def identifier
      "bus[#{@index}].device"
    end
  end
end
