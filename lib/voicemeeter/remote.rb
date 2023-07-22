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
require_relative "patch"
require_relative "option"
require_relative "configs"

module Voicemeeter
  module Builder
    private

    def steps
      {
        strip: -> { (0...kind.num_strip).map { Strip::Strip.make(self, _1) } },
        bus: -> { (0...kind.num_bus).map { Bus::Bus.make(self, _1) } },
        button: -> { (0...kind.num_buttons).map { Button::Button.new(self, _1) } },
        vban: -> { Vban::Vban.new(self) },
        command: -> { Command.new(self) },
        recorder: -> { Recorder::Recorder.new(self) },
        device: -> { Device.new(self) },
        fx: -> { Fx.new(self) },
        patch: -> { Patch::Patch.new(self) },
        option: -> { Option::Option.new(self) }
      }
    end

    def director
      [:strip, :bus, :button, :vban, :command, :device, :option]
    end
  end

  module Remote
    class Remote < Base
      include Builder

      public attr_reader :strip, :bus, :button, :vban, :command, :device, :option
      private attr_writer :strip, :bus, :button, :vban, :command, :device, :option

      def initialize(kind, **kwargs)
        super
        steps.select { |k, v| director.include? k }.each do |k, v|
          send("#{k}=", v.call)
        end
      end

      def configs
        Configs.get(kind.name)
      end

      def run
        login
        if event.any?
          init_event_threads
        end

        yield(self) if block_given?
      ensure
        end_event_threads
        logout
      end
    end

    class RemoteBasic < Remote
    end

    class RemoteBanana < Remote
      public attr_reader :recorder, :patch
      private attr_writer :recorder, :patch

      private def director
        super.append(:recorder, :patch)
      end
    end

    class RemotePotato < Remote
      public attr_reader :recorder, :patch, :fx
      private attr_writer :recorder, :patch, :fx

      private def director
        super.append(:recorder, :patch, :fx)
      end
    end

    class RequestRemote
      def self.for(kind, **kwargs)
        case kind.name
        when :basic
          RemoteBasic.new(kind, **kwargs)
        when :banana
          RemoteBanana.new(kind, **kwargs)
        when :potato
          RemotePotato.new(kind, **kwargs)
        end
      end
    end

    public

    def self.new(kind_id, **kwargs)
      kind = Kinds.get(kind_id)
    rescue KeyError
      raise Errors::VMError.new "unknown Voicemeeter kind #{kind_id}"
    else
      RequestRemote.for(kind, **kwargs)
    end
  end
end
