require_relative "base"
require_relative "kinds"
require_relative "errors"
require_relative "strip"
require_relative "bus"
require_relative "button"
require_relative "vban"
require_relative "configs"

module Voicemeeter
  module Remote
    include Configs

    private

    class Remote < Base
      attr_reader :strip, :bus, :button, :vban

      def initialize(kind, **kwargs)
        super
        @strip = []
        kind.num_strip.times { |i| @strip << Strip::Strip.make(self, i) }
        @bus = []
        kind.num_strip.times { |i| @bus << Bus::Bus.make(self, i) }
        @button = []
        kind.num_buttons.times { |i| @button << Button::Button.new(self, i) }
        @vban = Vban::Vban.new(self)
      end

      def configs
        Configs.load
        Configs.get(@kind.name)
      end
    end

    public

    def self.make(kind_id, **kwargs)
      "
      Factory method for remotes

      Wraps factory expression and handles errors

      Returns a Remote class of a Kind
      "
      remotes =
        Kinds::ALL.to_h { |kind| [kind.name, Remote.new(kind, **kwargs)] }
      unless remotes.key? kind_id
        raise Errors::VMError.new("unknown Voicemeeter kind #{kind_id}")
      end
      remotes[kind_id]
    end
  end
end
