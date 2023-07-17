require_relative "iremote"

module Voicemeeter
  module Patch
    class Patch < IRemote
      attr_reader :asio, :asioa2, :asioa3, :asioa4, :asioa5, :composite, :insert

      def initialize(remote)
        super
        make_accessor_bool :postfadercomposite, :postfxinsert

        asio_in, asio_out = remote.kind.asio
        @asio = (0...asio_in).map { |i| PatchAsioIn.new(remote, i) }
        @outa2 = (0...asio_out).map { |i| PatchAsioOut.new(remote, i) }
        @outa3 = (0...asio_out).map { |i| PatchAsioOut.new(remote, i) }
        @outa4 = (0...asio_out).map { |i| PatchAsioOut.new(remote, i) }
        @outa5 = (0...asio_out).map { |i| PatchAsioOut.new(remote, i) }
        @composite = (0...8).map { |i| PatchComposite.new(remote, i) }
        @insert = (0...remote.kind.insert).map { |i| PatchInsert.new(remote, i) }
      end
    end

    class PatchAsio < IRemote
      def identifier
        :patch
      end
    end

    class PatchAsioIn < PatchAsio
      def get
        getter("asio[#{@index}]").to_i
      end

      def set(val)
        setter("asio[#{@index}]", val)
      end
    end

    class PatchAsioOut < PatchAsio
      def get
        getter("asio[#{@index}]").to_i
      end

      def set(val)
        setter("asio[#{@index}]", val)
      end
    end

    class PatchComposite < IRemote
      def get
        getter("composite[#{@index}]").to_i
      end

      def set(val)
        setter("composite[#{@index}]", val)
      end
    end

    class PatchInsert < IRemote
      def get
        getter("insert[#{@index}]").to_i == 1
      end

      def set(val)
        setter("insert[#{@index}]", val && 1 || 0)
      end
    end
  end
end
