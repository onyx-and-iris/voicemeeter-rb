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
      extend MetaFunctions
      attr_accessor_float :returnreverb, :returndelay, :returnfx1, :returnfx2
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
      def make_attr_outputs(num_a, num_b)
        (1..(num_a + num_b)).each do |i|
          param = (i <= num_a) ? :"A#{i}" : :"B#{i - num_a}"
          define_singleton_method(param) do
            getter(param).to_i == 1
          end
          define_singleton_method("#{param}=") do |value|
            setter(param, value && 1 || 0)
          end
        end
      end
    end

    module Xy
      module Pan
        extend MetaFunctions
        attr_accessor_float :pan_x, :pan_y
      end

      module Color
        extend MetaFunctions
        attr_accessor_float :color_x, :color_y
      end

      module Fx
        extend MetaFunctions
        attr_accessor_float :fx_x, :fx_y
      end
    end

    module Fx
      extend MetaFunctions
      attr_accessor_float :reverb, :delay, :fx1, :fx2
      attr_accessor_bool :postreverb, :postdelay, :postfx1, :postfx2
    end

    module LevelEnum
      PREFADER = 0
      POSTFADER = 1
      POSTMUTE = 2
      BUS = 3
    end
  end
end
