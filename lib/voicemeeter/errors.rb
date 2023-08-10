module Voicemeeter
  module Errors
    class VMError < StandardError; end
    # Base Voicemeeter error class

    class VMInstallError < VMError; end
    # Errors raised during installation.

    class VMCAPIError < VMError
      # Errors raised when the C-API returns error codes
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
