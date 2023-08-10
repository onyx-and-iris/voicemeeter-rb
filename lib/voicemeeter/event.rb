module Voicemeeter
  module Events
    module Callback
      def callbacks
        @callbacks ||= []
      end

      def register(cbs)
        cbs = [cbs] unless cbs.respond_to? :each
        cbs.each { |cb| callbacks << cb unless callbacks.include? cb }
      end

      def deregister(cbs)
        cbs = [cbs] unless cbs.respond_to? :each
        callbacks.reject! { |cb| cbs.include? cb }
      end

      private def trigger(event)
        callbacks.each do |callback|
          if callback.is_a? Method
            callback.call if callback.name == "on_#{event}".to_sym
          elsif callback.respond_to? :on_update
            callback.on_update event
          end
        end
      end
    end

    class Tracker
      include Logging

      attr_reader :pdirty, :mdirty, :midi, :ldirty

      def initialize(**kwargs)
        make_writer_methods :pdirty, :mdirty, :midi, :ldirty

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

      private def make_writer_methods(*params)
        params.each do |param|
          define_singleton_method("#{param}=") do |value|
            instance_variable_set("@#{param}", value)
            info("#{param} #{value ? "added to" : "removed from"}")
          end
        end
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
