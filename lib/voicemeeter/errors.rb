module Voicemeeter
  module Errors
    class VMError < StandardError
    end

    class VMCAPIError < VMError
    end
  end
end
