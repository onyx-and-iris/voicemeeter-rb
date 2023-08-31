module Voicemeeter
  # Builder module for Remote factories.
  module Builder
    private

    def steps(step)
      case step
      when :strip then -> { (0...kind.num_strip).map { Strip::Base.make(self, _1) } }
      when :bus then -> { (0...kind.num_bus).map { Bus::Base.make(self, _1) } }
      when :button then -> { (0...kind.num_buttons).map { Button::Base.new(self, _1) } }
      when :vban then -> { Vban::Base.new(self) }
      when :command then -> { Command.new(self) }
      when :recorder then -> { Recorder::Base.new(self) }
      when :device then -> { Device.new(self) }
      when :fx then -> { Fx.new(self) }
      when :patch then -> { Patch::Base.new(self) }
      when :option then -> { Option::Base.new(self) }
      end
    end

    def director
      %i[strip bus button vban command device option]
    end
  end

  module Remote
    extend Logging

    # Concrete class for Remote
    class Remote < Base
      include Builder

      public attr_reader :strip, :bus, :button, :vban, :command, :device, :option

      def initialize(...)
        super
        director.each { |step| instance_variable_set("@#{step}", steps(step).call) }
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

    # Represents a Basic Remote
    class RemoteBasic < Remote; end

    # Represents a Banana Remote
    class RemoteBanana < Remote
      public attr_reader :recorder, :patch

      private def director
        super | [:recorder, :patch]
      end
    end

    # Represents a Potato Remote
    class RemotePotato < Remote
      public attr_reader :recorder, :patch, :fx

      private def director
        super | [:recorder, :patch, :fx]
      end
    end

    # Factory class for Remote. Returns a Remote class of a kind.
    class RequestRemote
      def self.for(kind, **)
        case kind.name
        when :basic
          RemoteBasic.new(kind, **)
        when :banana
          RemoteBanana.new(kind, **)
        when :potato
          RemotePotato.new(kind, **)
        end
      end
    end

    # Interface entry point. Wraps factory class and handles kind errors.
    def self.new(kind_id, **)
      kind = Kinds.get(kind_id)
    rescue KeyError => e
      logger.error "#{e.class.name}: #{e.message}"
      raise Errors::VMError.new "unknown Voicemeeter kind '#{kind_id}'"
    else
      RequestRemote.for(kind, **)
    end
  end
end
