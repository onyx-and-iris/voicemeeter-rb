module Voicemeeter
  module Mixins
    module Fades
      def fadeto(target, time)
        setter("FadeTo", "(#{target}, #{time})")
        sleep(@remote.delay)
      end

      def fadeby(change, time)
        setter("FadeBy", "(#{change}, #{time})")
        sleep(@remote.delay)
      end
    end

    module Return
      def initialize(remote, i)
        super
        make_accessor_float :returnreverb, :returndelay, :returnfx1, :returnfx2
      end
    end

    module Apps
      def appgain(name, gain)
        setter("AppGain", "(\"#{name}\", #{gain})")
      end

      def appmute(name, mute)
        setter("AppMute", "(\"#{name}\", #{mute ? 1 : 0})")
      end
    end

    module Outputs
      def initialize(*args)
        super
        remote, *_ = args
        num_a, num_b = remote.kind.outs
        channels =
          (1..(num_a + num_b)).map do |i|
            (i <= num_a) ? "A#{i}" : "B#{i - num_a}"
          end
        make_accessor_bool(*channels)
      end
    end

    module Xy
      module Pan
        def initialize(remote, i)
          super
          make_accessor_float :pan_x, :pan_y
        end
      end

      module Color
        def initialize(remote, i)
          super
          make_accessor_float :color_x, :color_y
        end
      end

      module Fx
        def initialize(remote, i)
          super
          make_accessor_float :fx_x, :fx_y
        end
      end
    end

    module Fx
      def initialize(remote, i)
        super
        make_accessor_float :reverb, :delay, :fx1, :fx2
        make_accessor_bool :postreverb, :postdelay, :postfx1, :postfx2
      end
    end

    module LevelEnum
      PREFADER = 0
      POSTFADER = 1
      POSTMUTE = 2
      BUS = 3
    end
  end
end
