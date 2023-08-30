module Voicemeeter
  module Option
    class Base
      include IRemote
      extend MetaFunctions

      attr_reader :delay, :buffer, :mode
      attr_accessor_int :sr
      attr_accessor_bool :asiosr, :monitoronsel, :slidermode

      def initialize(remote)
        super
        @delay = (0...remote.kind.phys_out).map { OptionDelay.new(remote, _1) }
        @buffer = OptionBuffer.new(remote)
        @mode = OptionMode.new(remote)
      end

      def identifier
        :option
      end
    end

    class OptionDelay
      include IRemote
      extend MetaFunctions

      attr_accessor_bool :on, :ab

      def identifier
        "option.delay"
      end

      def get
        getter("[#{@index}]").to_i
      end

      def set(val)
        setter("[#{@index}]", val)
      end
    end

    class OptionBuffer
      include IRemote
      extend MetaFunctions

      attr_accessor_int :mme, :wdm, :ks, :asio

      def identifier
        "option.buffer"
      end
    end

    class OptionMode
      include IRemote
      extend MetaFunctions

      attr_accessor_bool :exclusif, :swift

      def identifier
        "option.mode"
      end
    end
  end
end
