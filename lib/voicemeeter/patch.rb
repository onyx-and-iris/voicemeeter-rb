module Voicemeeter
  module Patch
    # Base class for Patch
    class Base
      include IRemote
      attr_reader :asio, :A2, :A3, :A4, :A5, :composite, :insert

      def initialize(remote)
        super
        make_accessor_bool :postfadercomposite, :postfxinsert

        asio_in, asio_out = remote.kind.asio
        @asio = (0...asio_in).map { PatchAsioIn.new(remote, _1) }
        %i[A2 A3 A4 A5].each do |param|
          instance_variable_set("@#{param}", (0...asio_out).map { PatchAsioOut.new(remote, _1, param) })
        end
        @composite = (0...8).map { PatchComposite.new(remote, _1) }
        @insert = (0...remote.kind.insert).map { PatchInsert.new(remote, _1) }
      end
    end

    class PatchAsio
      include IRemote

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
      def initialize(remote, i, param)
        super(remote, i)
        @param = param
      end

      def get
        getter("out#{@param}[#{@index}]").to_i
      end

      def set(val)
        setter("out#{@param}[#{@index}]", val)
      end
    end

    class PatchComposite
      include IRemote

      def get
        getter("composite[#{@index}]").to_i
      end

      def set(val)
        setter("composite[#{@index}]", val)
      end
    end

    class PatchInsert
      include IRemote

      def get
        getter("insert[#{@index}]").to_i == 1
      end

      def set(val)
        setter("insert[#{@index}]", val && 1 || 0)
      end
    end
  end
end
