require_relative "logger"

module Voicemeeter
  module Events
    class Callback
      def initialize
        @callbacks = []
      end

      def register(*args)
        args.each { |callback| @callbacks.append callback }
      end

      def deregister(*args)
        @callbacks.reject! { |c| args.include? c }
      end

      def trigger(event)
        @callbacks.each do |callback|
          if callback.respond_to? :on_update
            callback.on_update event.to_s[3..]
          elsif callback.name == event
            callback.call
          end
        end
      end
    end

    class Tracker
      include Logging

      attr_reader :pdirty, :mdirty, :midi, :ldirty

      def initialize(pdirty: false, mdirty: false, midi: false, ldirty: false)
        @pdirty = pdirty
        @mdirty = mdirty
        @midi = midi
        @ldirty = ldirty
      end

      def to_s
        self.class.name.split("::").last.to_s
      end

      def info(msg = nil)
        info_msg = msg ? ["#{msg} events."] : []
        info_msg += if any?
          ["Now listening for #{get.join(", ")} events"]
        else
          ["Not listening for any events"]
        end
        logger.info(info_msg.join(" "))
      end

      def pdirty=(val)
        @pdirty = val
        info("pdirty #{val ? "added to" : "removed from"}")
      end

      def mdirty=(val)
        @mdirty = val
        info("mdirty #{val ? "added to" : "removed from"}")
      end

      def ldirty=(val)
        @ldirty = val
        info("ldirty #{val ? "added to" : "removed from"}")
      end

      def midi=(val)
        @midi = val
        info("midi #{val ? "added to" : "removed from"}")
      end

      def get
        %i[pdirty mdirty midi ldirty].reject { |ev| !send(ev) }
      end

      def any?
        [pdirty, mdirty, midi, ldirty].any?
      end

      def add(events)
        events = [events] if !events.respond_to? :each
        events.each { |e| send("#{e}=", true) }
      end

      def remove(events)
        events = [events] if !events.respond_to? :each
        events.each { |e| send("#{e}=", false) }
      end
    end
  end
end
