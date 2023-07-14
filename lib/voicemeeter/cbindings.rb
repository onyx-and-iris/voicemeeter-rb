require_relative "install"
require_relative "errors"
require_relative "core_extensions/string/snakecase"

module Voicemeeter
  module CBindings
    private

    extend FFI::Library

    VM_PATH = Install.get_vmpath

    ffi_lib VM_PATH.join(
      "VoicemeeterRemote#{(Install::OS_BITS == 64) ? "64" : "32"}.dll"
    )
    ffi_convention :stdcall

    class << self
      private

      def self.attach_function(c_name, args, returns)
        ruby_name = "bind_#{c_name.to_s.delete_prefix("VBVMR_").snakecase}".to_sym
        super(ruby_name, c_name, args, returns)
      end
    end

    attach_function :VBVMR_Login, [], :long
    attach_function :VBVMR_Logout, [], :long
    attach_function :VBVMR_RunVoicemeeter, [:long], :long
    attach_function :VBVMR_GetVoicemeeterType, [:pointer], :long
    attach_function :VBVMR_GetVoicemeeterVersion, [:pointer], :long
    attach_function :VBVMR_MacroButton_IsDirty, [], :long
    attach_function :VBVMR_MacroButton_GetStatus, %i[long pointer long], :long
    attach_function :VBVMR_MacroButton_SetStatus, %i[long float long], :long

    attach_function :VBVMR_IsParametersDirty, [], :long
    attach_function :VBVMR_GetParameterFloat, %i[string pointer], :long
    attach_function :VBVMR_SetParameterFloat, %i[string float], :long

    attach_function :VBVMR_GetParameterStringA, %i[string pointer], :long
    attach_function :VBVMR_SetParameterStringA, %i[string string], :long

    attach_function :VBVMR_SetParameters, [:string], :long

    attach_function :VBVMR_GetLevel, %i[long long pointer], :long

    attach_function :VBVMR_Input_GetDeviceNumber, [], :long
    attach_function :VBVMR_Input_GetDeviceDescA,
      %i[long pointer pointer pointer],
      :long

    attach_function :VBVMR_Output_GetDeviceNumber, [], :long
    attach_function :VBVMR_Output_GetDeviceDescA,
      %i[long pointer pointer pointer],
      :long

    attach_function :VBVMR_GetMidiMessage, %i[pointer long], :long

    def call(fn, *args, ok: [0], exp: nil)
      res = send(fn, *args)
      if exp.nil?
        unless ok.include?(res)
          raise Errors::VMCAPIError.new("#{fn} returned #{res}")
        end
      else
        unless exp.call(res) && ok.include?(res)
          raise Errors::VMCAPIError.new("#{fn} returned #{res}")
        end
      end
      res
    end

    module_function :call
  end
end
