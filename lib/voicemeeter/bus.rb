require_relative "iremote"
require_relative "kinds"
require_relative "mixins"

module Voicemeeter
  module Bus
    class Bus < IRemote
      include Mixins::Fades
      include Mixins::Return

      attr_reader :eq, :mode, :levels

      def self.make(remote, i)
        p_out = remote.kind.phys_out
        (i < p_out) ? PhysicalBus.new(remote, i) : VirtualBus.new(remote, i)
      end

      def initialize(remote, i)
        super
        make_accessor_bool :mute, :mono, :sel, :monitor
        make_accessor_float :gain
        make_accessor_string :label

        @eq = BusEq.new(remote, i)
        @mode = BusModes.new(remote, i)
        @levels = BusLevels.new(remote, i)
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

  class BusLevels < IRemote
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

      vals = if @remote.running && @remote.event.ldirty
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

  class BusDevice < IRemote
    def initialize(remote, i)
      super
      make_reader_only :name, :sr
      make_writer_only :wdm, :ks, :mme, :asio
    end

    def identifier
      "bus[#{@index}].device"
    end
  end
end
