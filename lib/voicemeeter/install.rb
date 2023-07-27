require "win32/registry"
require "pathname"
require "ffi"

module Voicemeeter
  private

  module Install
    OS_BITS = (FFI::Platform::CPU.downcase == "x64") ? 64 : 32

    def get_vmpath
      reg_key = [
        :Software,
        ((OS_BITS == 64) ? :WOW6432Node : nil),
        :Microsoft,
        :Windows,
        :CurrentVersion,
        :Uninstall,
        :"VB:Voicemeeter {17359A74-1236-5467}"
      ]

      Win32::Registry::HKEY_LOCAL_MACHINE.open(
        reg_key.compact.join("\\")
      ) do |reg|
        value = reg[:UninstallString.to_s]

        Pathname.new(value).dirname
      end
    end

    module_function :get_vmpath
  end
end
