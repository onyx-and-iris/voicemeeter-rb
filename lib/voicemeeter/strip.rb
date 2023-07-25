require_relative "iremote"
require_relative "kinds"
require_relative "mixins"

module Voicemeeter
  module Strip
    class Strip < IRemote
      include Mixins::Outputs
      include Mixins::Fades

      attr_reader :gainlayer, :levels

      def self.make(remote, i)
        p_in = remote.kind.phys_in
        (i < p_in) ? PhysicalStrip.new(remote, i) : VirtualStrip.new(remote, i)
      end

      def initialize(remote, i)
        super
        make_accessor_bool :solo, :mute, :mono
        make_accessor_float :gain
        make_accessor_int :limit
        make_accessor_string :label

        @gainlayer = (0...8).map { GainLayer.new(remote, i, _1) }
        @levels = StripLevels.new(remote, i)
      end

      def identifier
        "strip[#{@index}]"
      end
    end

    class PhysicalStrip < Strip
      include Mixins::Xy::Pan
      include Mixins::Xy::Color
      include Mixins::Xy::Fx
      include Mixins::Fx

      attr_reader :comp, :gate, :denoiser, :eq, :device

      def initialize(remote, i)
        super
        make_accessor_float :audibility

        @comp = StripComp.new(remote, i)
        @gate = StripGate.new(remote, i)
        @denoiser = StripDenoiser.new(remote, i)
        @eq = StripEq.new(remote, i)
        @device = StripDevice.new(remote, i)
      end
    end

    class StripComp < IRemote
      def initialize(remote, i)
        super
        make_accessor_float :gainin,
          :ratio,
          :threshold,
          :attack,
          :release,
          :knee,
          :gainout
        make_accessor_bool :makeup
      end

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

    class StripGate < IRemote
      def initialize(remote, i)
        super
        make_accessor_float :threshold, :damping, :attack, :hold, :release
        make_accessor_int :bpsidechain
      end

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

    class StripDenoiser < IRemote
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

    class StripEq < IRemote
      def initialize(remote, i)
        super
        make_accessor_bool :on, :ab
      end

      def identifier
        "strip[#{@index}].eq"
      end
    end

    class StripDevice < IRemote
      def initialize(remote, i)
        super
        make_reader_int :sr
        make_reader_string :name
        make_writer_string :wdm, :ks, :mme, :asio
      end

      def identifier
        "strip[#{@index}].device"
      end
    end

    class VirtualStrip < Strip
      include Mixins::Xy::Pan
      include Mixins::Apps

      def initialize(remote, i)
        super
        make_accessor_bool :mc
        make_accessor_int :karaoke
      end

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

    class GainLayer < IRemote
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

    class StripLevels < IRemote
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
        vals = if @remote.running && @remote.event.ldirty
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
