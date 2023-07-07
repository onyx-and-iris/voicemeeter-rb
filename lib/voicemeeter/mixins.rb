module Voicemeeter
  module Mixins
    module StripMixins
      module Apps
        def appgain(name, gain)
          self.setter("AppGain", "(\"#{name}\", #{gain})")
        end

        def appmute(name, mute)
          self.setter("AppMute", "(\"#{name}\", #{mute ? 1 : 0})")
        end
      end

      module Xy
        include Meta_Functions

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
        include Meta_Functions

        def initialize(remote, i)
          super
          make_accessor_float :reverb, :delay, :fx1, :fx2
          make_accessor_bool :postreverb, :postdelay, :postfx1, :postfx2
        end
      end

      module Return
        include Meta_Functions

        def initialize(remote, i)
          super
          make_accessor_float :returnreverb,
                              :returndelay,
                              :returnfx1,
                              :returnfx2
        end
      end
    end
  end
end
