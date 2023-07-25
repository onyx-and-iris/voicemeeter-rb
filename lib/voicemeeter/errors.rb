require_relative "util"

module Voicemeeter
  module Errors
    class VMError < StandardError
    end

    class VMCAPIError < VMError
      attr_reader :fn_name, :code

      def initialize(fn_name, code)
        @fn_name = fn_name
        @code = code
        super(message)
      end

      def message
        "#{fn_name} returned #{code}"
      end
    end
  end
end
