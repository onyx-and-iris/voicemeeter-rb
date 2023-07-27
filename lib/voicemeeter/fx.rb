require_relative "iremote"

module Voicemeeter
  class Fx
    include IRemote
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

    def initialize(remote)
      super
      make_accessor_bool :on, :ab
    end

    def identifier
      "fx.reverb"
    end
  end

  class FxDelay
    include IRemote

    def initialize(remote)
      super
      make_accessor_bool :on, :ab
    end

    def identifier
      "fx.delay"
    end
  end
end
