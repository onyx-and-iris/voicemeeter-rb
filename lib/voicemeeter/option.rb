require_relative "iremote"

module Voicemeeter
  module Option
    class Option < IRemote
      attr_reader :delay, :buffer, :mode

      def initialize(remote)
        super
        make_accessor_int :sr
        make_accessor_bool :asiosr, :monitoronsel, :slidermode

        @delay = (0...remote.kind.phys_out).map { |i| OptionDelay(remote, i) }
        @buffer = OptionBuffer.new(remote)
        @mode = OptionMode.new(remote)
      end

      def identifier
        :option
      end
    end

    class OptionDelay < IRemote
      def initialize(remote, i)
        super
        make_accessor_bool :on, :ab
      end

      def identifier
        "option.delay"
      end

      def get
        getter("[#{i}]").to_i
      end

      def set(val)
        setter("[#{i}]", val)
      end
    end

    class OptionBuffer < IRemote
      def initialize(remote)
        super
        make_accessor_int :mme, :wdm, :ks, :asio
      end

      def identifier
        "option.buffer"
      end
    end

    class OptionMode < IRemote
      def initialize(remote)
        super
        make_accessor_bool :exclusif, :swift
      end

      def identifier
        "option.mode"
      end
    end
  end
end
