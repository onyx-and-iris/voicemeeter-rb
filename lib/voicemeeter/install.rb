module Voicemeeter
  private

  module Install
    extend Logging

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
        value = reg["UninstallString"]

        Pathname.new(value).dirname
      end
    rescue Win32::Registry::Error => e
      err_msg = [
        "#{e.class.name}: #{e.message}",
        *e.backtrace
      ]
      logger.error err_msg.join("\n")
      raise Errors::VMInstallError.new "unable to read Voicemeeter path from the registry"
    end

    module_function :get_vmpath
  end
end
