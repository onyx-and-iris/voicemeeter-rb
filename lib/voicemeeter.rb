require "yaml"
require "pathname"
require "win32/registry"
require "ffi"
require "date"
require "logger"

require_relative "voicemeeter/logger"
require_relative "voicemeeter/worker"
require_relative "voicemeeter/event"
require_relative "voicemeeter/util"
require_relative "voicemeeter/meta"
require_relative "voicemeeter/iremote"
require_relative "voicemeeter/mixins"
require_relative "voicemeeter/install"

require_relative "voicemeeter/base"
require_relative "voicemeeter/bus"
require_relative "voicemeeter/button"
require_relative "voicemeeter/cbindings"
require_relative "voicemeeter/command"
require_relative "voicemeeter/configs"
require_relative "voicemeeter/device"
require_relative "voicemeeter/fx"
require_relative "voicemeeter/kinds"
require_relative "voicemeeter/midi"
require_relative "voicemeeter/option"
require_relative "voicemeeter/patch"
require_relative "voicemeeter/recorder"
require_relative "voicemeeter/remote"
require_relative "voicemeeter/strip"
require_relative "voicemeeter/vban"

require_relative "voicemeeter/version"

module Voicemeeter
  module Errors
    # Base Voicemeeter error class
    class VMError < StandardError; end

    # Raised when errors occur during installation.
    class VMInstallError < VMError; end

    # Raised when the C-API returns error codes
    class VMCAPIError < VMError
      attr_reader :fn_name, :code

      # create a new VMCAPIError with given C-API function name and error code
      def initialize(fn_name, code)
        @fn_name = fn_name
        @code = code
        super("#{fn_name} returned #{code}")
      end
    end
  end
end
