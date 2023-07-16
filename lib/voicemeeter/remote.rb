require_relative "base"
require_relative "kinds"
require_relative "errors"
require_relative "strip"
require_relative "bus"
require_relative "button"
require_relative "vban"
require_relative "command"
require_relative "recorder"
require_relative "device"
require_relative "fx"
require_relative "configs"

module Voicemeeter
  module Remote
    private

    class Remote < Base
      def initialize(kind, **kwargs)
        super
        @strip = (0...kind.num_strip).map { |i| Strip::Strip.make(self, i) }
        @bus = (0...kind.num_bus).map { |i| Bus::Bus.make(self, i) }
        @button = (0...kind.num_buttons).map { |i| Button::Button.new(self, i) }
        @vban = Vban::Vban.new(self)
        @command = Command.new(self)
        @recorder = Recorder::Recorder.new(self)
        @device = Device.new(self)
        @fx = Fx.new(self)
      end

      def configs
        Configs.get(kind.name)
      end

      def run
        login

        yield(self) if block_given?

        logout
      end
    end

    class RemoteBasic < Remote
      attr_reader :strip, :bus, :button, :vban, :command, :device
    end

    class RemoteBanana < Remote
      attr_reader :strip, :bus, :button, :vban, :command, :device, :recorder
    end

    class RemotePotato < Remote
      attr_reader :strip, :bus, :button, :vban, :command, :device, :recorder, :fx
    end

    public

    def self.new(kind_id, **kwargs)
      kind = Kinds.get(kind_id)
    rescue KeyError
      raise Errors::VMError.new "unknown Voicemeeter kind #{kind_id}"
    else
      if kind_id == :basic
        RemoteBasic.new(kind, **kwargs)
      elsif kind_id == :banana
        RemoteBanana.new(kind, **kwargs)
      elsif kind_id == :potato
        RemotePotato.new(kind, **kwargs)
      end
    end
  end
end
