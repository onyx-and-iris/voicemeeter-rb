require_relative "install"
require_relative "errors"

module Voicemeeter
  module CBindings
    private

    extend FFI::Library

    VM_PATH = Install.get_vmpath()

    ffi_lib VM_PATH.join(
              "VoicemeeterRemote#{Install::OS_BITS == 64 ? "64" : "32"}.dll"
            )
    ffi_convention :stdcall

    attach_function :bind_login, :VBVMR_Login, [], :long
    attach_function :bind_logout, :VBVMR_Logout, [], :long
    attach_function :bind_runvm, :VBVMR_RunVoicemeeter, [:long], :long
    attach_function :bind_type, :VBVMR_GetVoicemeeterType, [:pointer], :long
    attach_function :bind_version,
                    :VBVMR_GetVoicemeeterVersion,
                    [:pointer],
                    :long

    attach_function :bind_mdirty, :VBVMR_MacroButton_IsDirty, [], :long
    attach_function :bind_get_buttonstatus,
                    :VBVMR_MacroButton_GetStatus,
                    %i[long pointer long],
                    :long
    attach_function :bind_set_buttonstatus,
                    :VBVMR_MacroButton_SetStatus,
                    %i[long float long],
                    :long

    attach_function :bind_pdirty, :VBVMR_IsParametersDirty, [], :long
    attach_function :bind_get_parameter_float,
                    :VBVMR_GetParameterFloat,
                    %i[string pointer],
                    :long
    attach_function :bind_set_parameter_float,
                    :VBVMR_SetParameterFloat,
                    %i[string float],
                    :long

    attach_function :bind_get_parameter_string,
                    :VBVMR_GetParameterStringA,
                    %i[string pointer],
                    :long
    attach_function :bind_set_parameter_string,
                    :VBVMR_SetParameterStringA,
                    %i[string string],
                    :long

    attach_function :bind_set_parameter_multi,
                    :VBVMR_SetParameters,
                    [:string],
                    :long

    attach_function :bind_get_level,
                    :VBVMR_GetLevel,
                    %i[long long pointer],
                    :long

    attach_function :bind_get_num_indevices,
                    :VBVMR_Input_GetDeviceNumber,
                    [],
                    :long
    attach_function :bind_get_desc_indevices,
                    :VBVMR_Input_GetDeviceDescA,
                    %i[long pointer pointer pointer],
                    :long

    attach_function :bind_get_num_outdevices,
                    :VBVMR_Output_GetDeviceNumber,
                    [],
                    :long
    attach_function :bind_get_desc_outdevices,
                    :VBVMR_Output_GetDeviceDescA,
                    %i[long pointer pointer pointer],
                    :long

    attach_function :bind_get_midi_message,
                    :VBVMR_GetMidiMessage,
                    %i[pointer long],
                    :long

    def call(fn, *args, ok: [0], exp: nil)
      res = send(fn, *args)
      if exp.nil?
        unless ok.include? res
          raise Errors::VMCAPIError.new("#{fn} returned #{res}")
        end
      else
        unless exp.call(res)
          raise Errors::VMCAPIError.new("#{fn} returned #{res}")
        end
      end
      res
    end

    module_function :call
  end
end
