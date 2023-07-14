require_relative "install"
require_relative "cbindings"
require_relative "kinds"
require_relative "midi"
require_relative "event"
require_relative "worker"
require "easy_logging"

module Voicemeeter
  class Base
    # include EasyLogging
    include Worker
    include Events::Callbacks

    attr_reader :kind, :midi, :event, :running
    attr_accessor :cache

    RATELIMIT = 0.033

    def initialize(kind, **kwargs)
      @kind = kind
      @sync = kwargs[:sync] || false
      @ratelimit = kwargs[:ratelimit] || RATELIMIT
      @midi = Midi.new
      @event =
        Events::Tracker.new(
          **(kwargs.select { |k, _| %i[pdirty mdirty ldirty midi].include? k })
        )
      @callbacks = []
      @que = Queue.new
      @cache = {strip_mode: 0}
    end

    def to_s
      "Voicemeeter #{kind}"
    end

    def login
      runvm if CBindings.call(:bind_login, ok: [0, 1]) == 1
      clear_dirty
      logger.info "Successfully logged into #{self} version #{version}"
      if event.any?
        init_worker(@que)
        init_producer(@que)
      end
    end

    def logout
      @running = false
      sleep(0.1)
      CBindings.call(:bind_logout)
      logger.info "Sucessfully logged out of #{self}"
    end

    def pdirty?
      CBindings.call(:bind_is_parameters_dirty, ok: [0, 1]) == 1
    end

    def mdirty?
      CBindings.call(:bind_macro_button_is_dirty, ok: [0, 1]) == 1
    end

    def ldirty?
      cache[:strip_buf], cache[:bus_buf] = _get_levels
      !(
        cache[:strip_level] == cache[:strip_buf] &&
          cache[:bus_level] == cache[:bus_buf]
      )
    end

    private

    def clear_dirty
      while pdirty? || mdirty?
      end
    end

    def runvm
      kinds = {
        basic: Kinds::KindEnum::BASIC,
        banana: Kinds::KindEnum::BANANA,
        potato: (Install::OS_BITS == 64) ? 6 : Kinds::KindEnum::POTATO
      }
      CBindings.call(:bind_run_voicemeeter, kinds[kind.name])
      sleep(1)
    end

    public

    def type
      ckind = FFI::MemoryPointer.new(:long, 1)
      CBindings.call(:bind_get_voicemeeter_type, ckind)
      kinds = {
        Kinds::KindEnum::BASIC => :basic,
        Kinds::KindEnum::BANANA => :banana,
        Kinds::KindEnum::POTATO => :potato
      }
      kinds[ckind.read_long]
    end

    def version
      cver = FFI::MemoryPointer.new(:long, 1)
      CBindings.call(:bind_get_voicemeeter_version, cver)
      [
        (cver.read_long & 0xFF000000) >> 24,
        (cver.read_long & 0x00FF0000) >> 16,
        (cver.read_long & 0x0000FF00) >> 8,
        cver.read_long & 0x000000FF
      ].join(".")
    end

    def get(name, is_string = false)
      clear_dirty if @sync
      if is_string
        c_get = FFI::MemoryPointer.new(:string, 512, true)
        CBindings.call(:bind_get_parameter_string_a, name, c_get)
        c_get.read_string
      else
        c_get = FFI::MemoryPointer.new(:float, 1)
        CBindings.call(:bind_get_parameter_float, name, c_get)
        c_get.read_float.round(1)
      end
    end

    def set(name, value)
      if value.is_a? String
        CBindings.call(:bind_set_parameter_string_a, name, value)
      else
        CBindings.call(:bind_set_parameter_float, name, value.to_f)
      end
    end

    def get_buttonstatus(id, mode)
      clear_dirty if @sync
      c_get = FFI::MemoryPointer.new(:float, 1)
      CBindings.call(:bind_macro_button_get_status, id, c_get, mode)
      c_get.read_float.to_i
    end

    def set_buttonstatus(id, state, mode)
      CBindings.call(:bind_macro_button_set_status, id, state, mode)
    end

    def get_level(mode, index)
      cget = FFI::MemoryPointer.new(:float, 1)
      CBindings.call(:bind_get_level, mode, index, cget)
      cget.read_float
    end

    def _get_levels
      [
        (0...kind.num_strip_levels).map do |i|
          get_level(cache[:strip_mode], i)
        end,
        (0...kind.num_bus_levels).map { |i| get_level(3, i) }
      ]
    end

    def get_num_devices(dir)
      unless %i[in out].include? dir
        raise VMError.new("dir got: #{dir}, expected in or out")
      end
      if dir == :in
        CBindings.call(:bind_input_get_device_number, exp: ->(x) { x >= 0 })
      else
        CBindings.call(:bind_output_get_device_number, exp: ->(x) { x >= 0 })
      end
    end

    def get_device_description(index, dir)
      unless %i[in out].include? dir
        raise VMError.new("dir got: #{dir}, expected in or out")
      end
      ctype = FFI::MemoryPointer.new(:long, 1)
      cname = FFI::MemoryPointer.new(:string, 256, true)
      chwid = FFI::MemoryPointer.new(:string, 256, true)
      if dir == :in
        CBindings.call(
          :bind_input_get_device_desc_a,
          index,
          ctype,
          cname,
          chwid
        )
      else
        CBindings.call(
          :bind_output_get_device_desc_a,
          index,
          ctype,
          cname,
          chwid
        )
      end
      [cname.read_string, ctype.read_long, chwid.read_string]
    end

    def get_midi_message
      cmsg = FFI::MemoryPointer.new(:string, 1024, true)
      res =
        CBindings.call(
          :bind_get_midi_message,
          cmsg,
          1024,
          ok: [-5, -6],
          exp: ->(x) { x >= 0 }
        )
      if (got_midi = res > 0)
        vals = cmsg.read_string_bytes
        vals.each_slice(3) do |ch, key, velocity|
          midi.channel = ch if midi.channel.nil? || midi.channel != ch
          midi.current = key.to_i
          midi.set(key.to_i, velocity.to_i)
        end
      end
      got_midi
    end

    def apply(data)
      data.each do |key, val|
        kls, index, *rem = key.to_s.split("-")
        if rem.empty?
          target = send(kls)
        else
          dir = "#{index.chomp("stream")}stream"
          index = rem[0]
          target = vban.send(dir)
        end
        target[index.to_i].apply(val)
      end
    end

    def apply_config(name)
      apply(configs[name])
      logger.info "profile #{name} applied!"
    end
  end
end
