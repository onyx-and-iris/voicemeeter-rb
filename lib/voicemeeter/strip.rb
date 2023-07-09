require_relative "iremote"
require_relative "kinds"
require_relative "mixins"

module Voicemeeter
  module Strip
    class Strip < IRemote
      include Mixins::StripMixins::Outputs
      include Mixins::StripMixins::Fades

      def self.make(remote, i)
        "
        Factory function for Strip classes.

        Returns a PhysicalStrip or VirtualStrip class
        "
        p_in, v_in = remote.kind.ins
        i < p_in ? PhysicalStrip.new(remote, i) : VirtualStrip.new(remote, i)
      end

      def initialize(remote, i)
        super
        make_accessor_bool :solo, :mute, :mono
        make_accessor_float :gain
        make_accessor_int :limit
        make_accessor_string :label
      end

      def identifier
        "strip[#{@index}]"
      end
    end

    class PhysicalStrip < Strip
      include Mixins::StripMixins::Xy::Pan
      include Mixins::StripMixins::Xy::Color
      include Mixins::StripMixins::Xy::Fx
      include Mixins::StripMixins::Fx

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
      def initialize(remote, i)
        super
      end

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
      include Mixins::StripMixins::Xy::Pan
      include Mixins::StripMixins::Apps

      def initialize(remote, i)
        super
        make_accessor_bool :mc
        make_accessor_int :k
        make_accessor_float :bass, :mid, :treble
      end
    end
  end
end
