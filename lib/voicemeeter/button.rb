require_relative "iremote"
require_relative "meta"

module Voicemeeter
  module Button
    module ButtonEnum
      STATE = 1
      STATEONLY = 2
      TRIGGER = 3
    end

    class MacroButton < IRemote
      def initialize(remote, i)
        super
      end

      def getter(mode)
        @remote.get_buttonstatus(@index, mode)
      end

      def setter(set, mode)
        @remote.set_buttonstatus(@index, set, mode)
      end

      def state
        getter(ButtonEnum::STATE)
      end

      def state=(value)
        setter(ButtonEnum::STATE, value && 1 || 0)
      end

      def stateonly
        getter(ButtonEnum::STATEONLY)
      end

      def stateonly=(value)
        setter(ButtonEnum::STATEONLY, value && 1 || 0)
      end

      def trigger
        getter(ButtonEnum::TRIGGER)
      end

      def trigger=(value)
        setter(ButtonEnum::TRIGGER, value && 1 || 0)
      end
    end
  end
end
