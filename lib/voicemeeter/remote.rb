module Voicemeeter
  module Builder
    # Builder module for Remote factories.
    # Defines steps for building a Remote type of a kind.
    # Defines the base director

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

    class Remote < Base
      # Concrete class for Remote types
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

    class RemoteBasic < Remote; end
    # Represents a RemoteBasic type

    class RemoteBanana < Remote
      # Represents a RemoteBanana type
      public attr_reader :recorder, :patch

      private def director
        super | [:recorder, :patch]
      end
    end

    class RemotePotato < Remote
      # Represents a RemotePotato type
      public attr_reader :recorder, :patch, :fx

      private def director
        super | [:recorder, :patch, :fx]
      end
    end

    class RequestRemote
      # Factory class for Remote types. Returns a Remote class of a kind.
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

    def self.new(kind_id, **)
      # Interface entry point. Wraps factory class and handles kind errors.
      kind = Kinds.get(kind_id)
    rescue KeyError => e
      logger.error "#{e.class.name}: #{e.message}"
      raise Errors::VMError.new "unknown Voicemeeter kind '#{kind_id}'"
    else
      RequestRemote.for(kind, **)
    end
  end
end
