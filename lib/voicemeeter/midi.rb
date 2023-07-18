module Voicemeeter
  class Midi
    attr_accessor :current, :channel
    attr_reader :cache

    def initialize
      @cache = {}
    end

    def get(key)
      cache[key]
    end
  end
end
