require_relative "util"

module Voicemeeter
  module Errors
    class VMError < StandardError
    end

    class VMCAPIError < VMError
      attr_reader :code

      def initialize(ruby_name, code)
        @ruby_name = ruby_name
        @code = code
        super(message)
      end

      def message
        "#{fn_name} returned #{code}"
      end

      def fn_name
        "VBVMR_#{Util.camelcase(@ruby_name.to_s.delete_prefix("bind_")).sub("macro_button", "macrobutton")}"
      end
    end
  end
end
