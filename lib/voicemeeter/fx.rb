module Voicemeeter
  class Fx
    include IRemote
    extend MetaFunctions

    attr_reader :reverb, :delay

    def initialize(remote)
      super
      @reverb = FxReverb.new(remote)
      @delay = FxDelay.new(remote)
    end

    def identifier
      :fx
    end
  end

  class FxReverb
    include IRemote
    extend MetaFunctions

    attr_accessor_bool :on, :ab

    def identifier
      "fx.reverb"
    end
  end

  class FxDelay
    include IRemote
    extend MetaFunctions

    attr_accessor_bool :on, :ab

    def identifier
      "fx.delay"
    end
  end
end
