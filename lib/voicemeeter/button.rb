require_relative "iremote"
require_relative "meta"

module Voicemeeter
  module Button
    module ButtonEnum
      STATE = 1
      STATEONLY = 2
      TRIGGER = 3
    end

    class Button < IRemote
      def getter(mode)
        @remote.get_buttonstatus(@index, mode)
      end

      def setter(mode, val)
        @remote.set_buttonstatus(@index, mode, val)
      end

      def state
        getter(ButtonEnum::STATE) == 1
      end

      def state=(value)
        setter(ButtonEnum::STATE, value && 1 || 0)
      end

      def stateonly
        getter(ButtonEnum::STATEONLY) == 1
      end

      def stateonly=(value)
        setter(ButtonEnum::STATEONLY, value && 1 || 0)
      end

      def trigger
        getter(ButtonEnum::TRIGGER) == 1
      end

      def trigger=(value)
        setter(ButtonEnum::TRIGGER, value && 1 || 0)
      end
    end
  end
end
