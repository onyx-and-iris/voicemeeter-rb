require_relative "logger"

module Voicemeeter
  module Worker
    include Logging

    def init_producer(que)
      Thread.new do
        while @running
          que << :pdirty if event.pdirty
          que << :mdirty if event.mdirty
          que << :midi if event.midi
          que << :ldirty if event.ldirty
          sleep(@ratelimit)
        end
        logger.debug("closing producer thread")
        que << :stop
      end
    end

    def init_worker(que)
      logger.info "Listening for #{event.get.join(", ")} events"
      @cache[:strip_level], @cache[:bus_level] = _get_levels
      @cache[:strip_comp] = Array.new(kind.num_strip_levels, false)
      @cache[:bus_comp] = Array.new(kind.num_bus_levels, false)
      @running = true
      Thread.new do
        loop do
          e_from_que = @que.pop
          if e_from_que == :stop
            logger.debug("closing worker thread")
            break
          end
          callback.trigger :on_pdirty if e_from_que == :pdirty && pdirty?
          callback.trigger :on_mdirty if e_from_que == :mdirty && mdirty?
          callback.trigger :on_midi if e_from_que == :midi && get_midi_message
          if e_from_que == :ldirty && ldirty?
            cache[:strip_comp] = cache[:strip_level].zip(cache[:strip_buf]).map { |a, b| a != b }
            cache[:bus_comp] = cache[:bus_level].zip(cache[:bus_buf]).map { |a, b| a != b }
            cache[:strip_level] = cache[:strip_buf]
            cache[:bus_level] = cache[:bus_buf]
            callback.trigger :on_ldirty
          end
        end
      end
    end

    def init_event_threads
      init_worker(@que)
      init_producer(@que)
    end

    def end_event_threads
      @running = false
    end

    module_function :init_event_threads, :end_event_threads
  end
end
