require "easy_logging"

module Voicemeeter
  module Worker
    include EasyLogging

    def init_producer(que)
      Thread.new do
        loop do
          que << :pdirty if event.pdirty
          que << :mdirty if event.mdirty
          que << :midi if event.midi
          que << :ldirty if event.ldirty
          if !@running
            que << :stop
            break
          end
          sleep(@ratelimit)
        end
      end
    end

    def init_worker(que)
      logger.info "Listening for #{event.get.join(", ")} events"
      @cache[:strip_level], @cache[:bus_level] = _get_levels
      @running = true
      Thread.new do
        loop do
          e_from_que = @que.pop
          if event == :stop
            break
            logger.debug("closing #{self} thread")
          end
          on_event :on_pdirty if e_from_que == :pdirty && pdirty?
          on_event :on_mdirty if e_from_que == :mdirty && mdirty?
          on_event :on_midi if e_from_que == :midi && get_midi_message
          if e_from_que == :ldirty && ldirty?
            @_strip_comp =
              cache[:strip_level].map.with_index do |x, i|
                !(x == @strip_buf[i])
              end
            @_bus_comp =
              cache[:bus_level].map.with_index { |x, i| !(x == @bus_buf[i]) }
            cache[:strip_level] = @strip_buf
            cache[:bus_level] = @bus_buf
            on_event :on_ldirty
          end
        end
      end
    end

    def end_worker
      @running = false
    end

    module_function :init_worker, :end_worker
  end
end
