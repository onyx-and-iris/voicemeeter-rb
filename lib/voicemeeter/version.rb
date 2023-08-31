module Voicemeeter
  module VERSION
    module_function

    def major
      1
    end

    def minor
      0
    end

    def patch
      0
    end

    def to_a
      [major, minor, patch]
    end

    def to_s
      to_a.join(".")
    end
  end
end
