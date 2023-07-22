require_relative "iremote"

module Voicemeeter
  module Patch
    class Patch < IRemote
      attr_reader :asio, :asioa2, :asioa3, :asioa4, :asioa5, :composite, :insert

      def initialize(remote)
        super
        make_accessor_bool :postfadercomposite, :postfxinsert

        asio_in, asio_out = remote.kind.asio
        @asio = (0...asio_in).map { PatchAsioIn.new(remote, _1) }
        @outa2 = (0...asio_out).map { PatchAsioOut.new(remote, _1) }
        @outa3 = (0...asio_out).map { PatchAsioOut.new(remote, _1) }
        @outa4 = (0...asio_out).map { PatchAsioOut.new(remote, _1) }
        @outa5 = (0...asio_out).map { PatchAsioOut.new(remote, _1) }
        @composite = (0...8).map { PatchComposite.new(remote, _1) }
        @insert = (0...remote.kind.insert).map { PatchInsert.new(remote, _1) }
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
