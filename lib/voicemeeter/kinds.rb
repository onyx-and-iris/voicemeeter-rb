module Voicemeeter
  module Kinds
    private

    KindMap =
      Data.define(:name, :ins, :outs, :vban, :asio, :insert, :num_buttons) do
        def phys_in = ins[0]

        def virt_in = ins[1]

        def phys_out = outs[0]

        def virt_out = outs[1]

        def num_strip = ins.sum

        def num_bus = outs.sum

        def num_strip_levels = 2 * phys_in + 8 * virt_in

        def num_bus_levels = 8 * (phys_out + virt_out)

        def to_s = name.to_s.capitalize
      end

    basic = KindMap.new(:basic, [2, 1], [1, 1], [4, 4], [0, 0], 0, 80)

    banana = KindMap.new(:banana, [3, 2], [3, 2], [8, 8], [6, 8], 22, 80)

    potato = KindMap.new(:potato, [5, 3], [5, 3], [8, 8], [10, 8], 34, 80)

    KIND_MAPS = [basic, banana, potato].to_h { |kind| [kind.name, kind] }

    module KindEnum
      BASIC = 1
      BANANA = 2
      POTATO = 3
    end

    public

    def get(kind_id)
      KIND_MAPS.fetch(kind_id)
    end

    ALL = KIND_MAPS.values

    module_function :get
  end
end
