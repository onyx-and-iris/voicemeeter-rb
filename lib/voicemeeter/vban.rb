module Voicemeeter
  module Vban
    # Base class for Vban Stream types
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

    # Represents a Vban InStream
    class VbanInstream < VbanStream
      def initialize(remote, i)
        super
        make_reader_int :sr, :channel, :bit
      end

      def direction
        :in
      end
    end

    # Represents a Vban Audio InStream
    class VbanAudioInstream < VbanInstream; end

    # Represents a Vban Midi InStream
    class VbanMidiInstream < VbanInstream; end

    # Represents a Vban Text InStream
    class VbanTextInstream < VbanInstream; end

    # Represents a Vban OutStream
    class VbanOutstream < VbanStream
      def initialize(remote, i)
        super
        make_accessor_int :sr, :channel, :bit
      end

      def direction
        :out
      end
    end

    # Represents a Vban Audio OutStream
    class VbanAudioOutstream < VbanOutstream; end

    # Represents a Vban Midi OutStream
    class VbanMidiOutstream < VbanOutstream; end

    class RequestVbanStream
      def self.for(remote, i, dir)
        vban_in, vban_out, midi, _ = remote.kind.vban
        case dir
        when :in
          if i < vban_in
            VbanAudioInstream.new(remote, i)
          elsif i < vban_in + midi
            VbanMidiInstream.new(remote, i)
          else
            VbanTextInstream.new(remote, i)
          end
        when :out
          if i < vban_out
            VbanAudioOutstream.new(remote, i)
          elsif i < vban_out + midi
            VbanMidiOutstream.new(remote, i)
          end
        end
      end
    end

    # Base class for Vban type
    class Base
      attr_reader :instream, :outstream

      def initialize(remote)
        vban_in, vban_out, midi, text = remote.kind.vban
        @instream = (0...vban_in + midi + text).map { RequestVbanStream.for(remote, _1, :in) }
        @outstream = (0...vban_out + midi).map { RequestVbanStream.for(remote, _1, :out) }

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
