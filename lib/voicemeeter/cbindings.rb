module Voicemeeter
  # Ruby bindings for the C-API functions
  module CBindings
    private

    extend Logging
    extend FFI::Library

    VM_PATH = Install.get_vmpath

    ffi_lib VM_PATH.join(
      "VoicemeeterRemote#{(Install::OS_BITS == 64) ? "64" : "32"}.dll"
    )
    ffi_convention :stdcall

    private_class_method def self.attach_function(c_name, args, returns)
      ruby_name = "bind_#{Util::String.snakecase(c_name.to_s.delete_prefix("VBVMR_"))}".to_sym
      super(ruby_name, c_name, args, returns)
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
      to_cname = -> {
        "VBVMR_#{Util::String.camelcase(fn.to_s.delete_prefix("bind_"))
        .gsub(/(Button|Input|Output)/, '\1_')}"
      }

      res = send(fn, *args)
      if exp
        unless exp.call(res) || ok.include?(res)
          raise Errors::VMCAPIError.new to_cname.call, res
        end
      else
        unless ok.include?(res)
          raise Errors::VMCAPIError.new to_cname.call, res
        end
      end
      res
    rescue Errors::VMCAPIError => e
      err_msg = [
        "#{e.class.name}: #{e.message}",
        *e.backtrace
      ]
      logger.error err_msg.join("\n")
      raise
    end

    module_function :call
  end
end
