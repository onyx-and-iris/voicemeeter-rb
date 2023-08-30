module Voicemeeter
  module Strip
    # Base class for Strip
    class Base
      include IRemote
      include Mixins::Outputs
      include Mixins::Fades
      extend MetaFunctions

      attr_reader :gainlayer, :levels
      attr_accessor_bool :solo, :mute, :mono
      attr_accessor_float :gain
      attr_accessor_int :limit
      attr_accessor_string :label

      def self.make(remote, i)
        (i < remote.kind.phys_in) ? PhysicalStrip.new(remote, i) : VirtualStrip.new(remote, i)
      end

      def initialize(remote, i)
        super
        make_attr_outputs(*remote.kind.outs)

        @gainlayer = (0...8).map { GainLayer.new(remote, i, _1) }
        @levels = StripLevels.new(remote, i)
      end

      def identifier
        "strip[#{@index}]"
      end
    end

    # Represents a Physical Strip
    class PhysicalStrip < Base
      include Mixins::Xy::Pan
      include Mixins::Xy::Color
      include Mixins::Xy::Fx
      include Mixins::Fx
      extend MetaFunctions

      attr_reader :comp, :gate, :denoiser, :eq, :device
      attr_accessor_float :audibility

      def initialize(remote, i)
        super
        @comp = StripComp.new(remote, i)
        @gate = StripGate.new(remote, i)
        @denoiser = StripDenoiser.new(remote, i)
        @eq = StripEq.new(remote, i)
        @device = StripDevice.new(remote, i)
      end
    end

    class StripComp
      include IRemote
      extend MetaFunctions

      attr_accessor_float :gainin,
        :ratio,
        :threshold,
        :attack,
        :release,
        :knee,
        :gainout
      attr_accessor_bool :makeup

      def identifier
        "strip[#{@index}].comp"
      end

      def knob
        getter("")
      end

      def knob=(val)
        setter("", val)
      end
    end

    class StripGate
      include IRemote
      extend MetaFunctions

      attr_accessor_float :threshold, :damping, :attack, :hold, :release
      attr_accessor_int :bpsidechain

      def identifier
        "strip[#{@index}].gate"
      end

      def knob
        getter("")
      end

      def knob=(val)
        setter("", val)
      end
    end

    class StripDenoiser
      include IRemote

      def identifier
        "strip[#{@index}].denoiser"
      end

      def knob
        getter("")
      end

      def knob=(val)
        setter("", val)
      end
    end

    class StripEq
      include IRemote
      extend MetaFunctions

      attr_accessor_bool :on, :ab

      def identifier
        "strip[#{@index}].eq"
      end
    end

    class StripDevice
      include IRemote
      extend MetaFunctions

      attr_reader_int :sr
      attr_reader_string :name
      attr_writer_string :wdm, :ks, :mme, :asio

      def identifier
        "strip[#{@index}].device"
      end
    end

    # Represents a Virtual Strip
    class VirtualStrip < Base
      include Mixins::Xy::Pan
      include Mixins::Apps
      extend MetaFunctions

      attr_accessor_bool :mc
      attr_accessor_int :karaoke

      def bass
        round(getter("EQGain1"), 1)
      end

      def bass=(val)
        setter("EQGain1", val)
      end

      def mid
        round(getter("EQGain2"), 1)
      end

      def mid=(val)
        setter("EQGain2", val)
      end

      def treble
        round(getter("EQGain3"), 1)
      end

      def treble=(val)
        setter("EQGain3", val)
      end

      alias_method :med, :mid
      alias_method :med=, :mid=
      alias_method :high, :treble
      alias_method :high=, :treble=
    end

    class GainLayer
      include IRemote

      def initialize(remote, i, j)
        super(remote, i)
        @j = j
      end

      def identifier
        "strip[#{@index}]"
      end

      def gain
        getter("gainlayer[#{@j}]")
      end

      def gain=(value)
        setter("gainlayer[#{@j}]", value)
      end
    end

    class StripLevels
      include IRemote

      def initialize(remote, i)
        super
        p_in = remote.kind.phys_in
        if i < p_in
          @init = i * 2
          @offset = 2
        else
          @init = (p_in * 2) + ((i - p_in) * 8)
          @offset = 8
        end
      end

      def identifier
        "strip[#{@index}]"
      end

      def get_level(mode)
        convert = ->(x) { (x > 0) ? (20 * Math.log(x, 10)).round(1) : -200.0 }

        @remote.cache[:strip_mode] = mode
        vals = if @remote.running? && @remote.event.ldirty
          @remote.cache[:strip_level][@init, @offset]
        else
          (@init...@init + @offset).map { |i| @remote.get_level(mode, i) }
        end
        vals.map(&convert)
      end

      def prefader
        get_level(Mixins::LevelEnum::PREFADER)
      end

      def postfader
        get_level(Mixins::LevelEnum::POSTFADER)
      end

      def postmute
        get_level(Mixins::LevelEnum::POSTMUTE)
      end

      def isdirty? = @remote.cache[:strip_comp][@init, @offset].any?
    end
  end
end
