require_relative "iremote"
require_relative "meta"
require_relative "errors"

module Voicemeeter
  module Vban
    class VbanStream < IRemote
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
        raise "Called abstract mehod: direction"
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

    class Vban
      attr_reader :instream, :outstream

      def initialize(remote)
        vban_in, vban_out = remote.kind.vban
        @instream = (0...vban_in).map { |i| VbanInstream.new(remote, i) }
        @outstream = (0...vban_out).map { |i| VbanOutstream.new(remote, i) }

        @remote = remote
      end

      # stree-ignore
      def enable
        @remote.set("vban.enable", 1)
      end

      # stree-ignore
      def disable
        @remote.set("vban.enable", 0)
      end
    end
  end
end
