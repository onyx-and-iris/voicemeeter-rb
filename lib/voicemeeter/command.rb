require_relative "iremote"
require_relative "meta"

module Voicemeeter
  class Command
    include IRemote

    def initialize(remote)
      super
      make_action_method :show, :restart, :shutdown
      make_writer_bool :showvbanchat, :lock
    end

    def identifier
      :command
    end

    def hide
      setter("show", 0)
    end

    def load(value)
      raise VMError.new("load got: #{value}, but expected a string") unless value.is_a? String
      setter("load", value)
      sleep(0.2)
    end

    def save(value)
      raise VMError.new("save got: #{value}, but expected a string") unless value.is_a? String
      setter("save", value)
      sleep(0.2)
    end

    def reset
      @remote.apply_config(:reset)
    end
  end
end
