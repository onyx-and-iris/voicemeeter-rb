require_relative "iremote"

module Voicemeeter
  class Fx < IRemote
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

  class FxReverb < IRemote
    def initialize(remote)
      super
      make_accessor_bool :on, :ab
    end

    def identifier
      "fx.reverb"
    end
  end

  class FxDelay < IRemote
    def initialize(remote)
      super
      make_accessor_bool :on, :ab
    end

    def identifier
      "fx.delay"
    end
  end
end
