module Voicemeeter
  class Midi
    attr_accessor :cache, :current, :channel

    def initialize
      @cache = Hash.new
    end

    def get(key)
      @cache[key]
    end

    def set(key, velocity)
      @cache[key] = velocity
    end
  end
end
