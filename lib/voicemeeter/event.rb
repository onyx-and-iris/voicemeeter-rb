module Voicemeeter
  module Events
    module Director
      def observers
        @observers ||= {}
      end

      def on(event, method = nil, &block)
        (observers[event] ||= []) << (block || method)
      end

      def register(cbs)
        cbs = Array(cbs) unless cbs.respond_to? :each
        cbs.each { |cb| on(cb.name[3..].to_sym, cb) }
      end

      def deregister(cbs)
        cbs = Array(cbs) unless cbs.respond_to? :each
        cbs.each { |cb| observers[cb.name[3..].to_sym]&.reject! { |o| cbs.include? o } }
      end

      def fire(event)
        observers[event]&.each { |block| block.call }
      end
    end

    class Tracker
      include Logging

      class << self
        private def attr_accessor_events(*params)
          params.each do |param|
            attr_reader param

            define_method("#{param}=") do |value|
              instance_variable_set("@#{param}", value)
              info("#{param} #{value ? "added to" : "removed from"}")
            end
          end
        end
      end

      attr_accessor_events :pdirty, :mdirty, :midi, :ldirty

      def initialize(**kwargs)
        kwargs.each do |key, value|
          instance_variable_set("@#{key}", value || false)
        end
      end

      def to_s
        self.class.name.split("::").last.to_s
      end

      def info(msg = nil)
        info_msg = msg ? ["#{msg} events."] : []
        info_msg << if any?
          ["Now listening for #{get.join(", ")} events"]
        else
          ["Not listening for any events"]
        end
        logger.info info_msg.join(" ")
      end

      def get
        %i[pdirty mdirty midi ldirty].reject { |ev| !send(ev) }
      end

      def any?
        [pdirty, mdirty, midi, ldirty].any?
      end

      def add(events)
        events = [events] unless events.respond_to? :each
        events.each { |e| send("#{e}=", true) }
      end

      def remove(events)
        events = [events] unless events.respond_to? :each
        events.each { |e| send("#{e}=", false) }
      end
    end
  end
end
