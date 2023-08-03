require_relative "logger"

module Voicemeeter
  module Worker
    # Event threads, provides updates to observers

    include Logging

    private

    def init_producer(que)
      @running = true
      Thread.new do
        Thread.current.name = "producer"
        while @running
          que << :pdirty if event.pdirty
          que << :mdirty if event.mdirty
          que << :midi if event.midi
          que << :ldirty if event.ldirty
          sleep(@ratelimit)
        end
        logger.debug "closing #{Thread.current.name} thread"
        que << @running
      end
    end

    def init_worker(que)
      logger.info "Listening for #{event.get.join(", ")} events"
      @cache[:strip_level], @cache[:bus_level] = _get_levels
      @cache[:strip_comp] = Array.new(kind.num_strip_levels, false)
      @cache[:bus_comp] = Array.new(kind.num_bus_levels, false)
      Thread.new do
        Thread.current.name = "worker"
        while (event = que.pop)
          trigger :pdirty if event == :pdirty && pdirty?
          trigger :mdirty if event == :mdirty && mdirty?
          trigger :midi if event == :midi && get_midi_message
          if event == :ldirty && ldirty?
            cache[:strip_comp] = cache[:strip_level].zip(cache[:strip_buf]).map { |a, b| a != b }
            cache[:bus_comp] = cache[:bus_level].zip(cache[:bus_buf]).map { |a, b| a != b }
            cache[:strip_level] = cache[:strip_buf]
            cache[:bus_level] = cache[:bus_buf]
            trigger :ldirty
          end
        end
        logger.debug "closing #{Thread.current.name} thread"
      end
    end

    public

    def init_event_threads
      que = Queue.new
      init_worker(que)
      init_producer(que)
    end

    def end_event_threads
      @running = false
    end
  end
end
