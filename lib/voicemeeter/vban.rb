require_relative "iremote"
require_relative "meta"
require_relative "errors"

module Voicemeeter
  module Vban
    class VbanStream
      include IRemote

      def initialize(remote, i)
        super
        make_accessor_bool :on
        make_accessor_string :name, :ip
        make_accessor_int :quality, :route
      end

      def identifier
        "vban.#{direction}stream[#{@index}]"
      end

      def direction
        raise "Called abstract method: direction"
      end
    end

    class VbanInstream < VbanStream
      def initialize(remote, i)
        super
        make_reader_int :sr, :channel, :bit
      end

      def direction
        :in
      end
    end

    class VbanOutstream < VbanStream
      def initialize(remote, i)
        super
        make_accessor_int :sr, :channel, :bit
      end

      def direction
        :out
      end
    end

    class Base
      # Base class for Vban type
      attr_reader :instream, :outstream

      def initialize(remote)
        vban_in, vban_out = remote.kind.vban
        @instream = (0...vban_in).map { VbanInstream.new(remote, _1) }
        @outstream = (0...vban_out).map { VbanOutstream.new(remote, _1) }

        @remote = remote
      end

      def enable
        @remote.set("vban.enable", 1)
      end

      def disable
        @remote.set("vban.enable", 0)
      end
    end
  end
end
