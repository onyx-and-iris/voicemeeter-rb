require_relative "iremote"
require_relative "meta"
require_relative "errors"

module Voicemeeter
  module Vban
    class VbanStream < IRemote
      "
      A class representing a VBAN stream
      "
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
      "
      A subclass representing a VBAN Instream
      "
      def initialize(remote, i)
        super
        make_reader_int :sr, :channel, :bit
      end

      def direction
        :in
      end
    end

    class VbanOutstream < VbanStream
      "
      A subclass representing a VBAN Outstream
      "
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
        "
        Initializes a Vban class

        Creates an array for each in/out stream and sets as class attributes
        "
        vban_in, vban_out = remote.kind.vban
        @instream = []
        vban_in.times { |i| @instream << VbanInstream.new(remote, i) }
        @outstream = []
        vban_out.times { |i| @outstream << VbanOutstream.new(remote, i) }

        @remote = remote
      end

      #stree-ignore
      def enable
        @remote.set("vban.enable", 1)
      end

      #stree-ignore
      def disable
        @remote.set("vban.enable", 0)
      end
    end
  end
end
