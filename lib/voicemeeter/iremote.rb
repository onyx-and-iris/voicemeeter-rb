require_relative "errors"
require_relative "meta"
require "easy_logging"

module Voicemeeter
  class IRemote
    "
    Common interface between base class and higher classes.
    "
    include EasyLogging
    include Meta_Functions

    def initialize(remote, i = nil)
      @remote = remote
      @index = i
    end

    def to_s
      "#{self.class.name.split("::").last}#{@index}#{@remote.kind}"
    end

    def getter(param, is_string = false)
      logger.debug "getter: #{_cmd(param)}"
      @remote.get(_cmd(param), is_string)
    end

    def setter(param, value)
      logger.debug "setter: #{_cmd(param)}=#{value}"
      @remote.set(_cmd(param), value)
    end

    def _cmd(param)
      param.empty? ? self.identifier : "#{self.identifier}.#{param}"
    end

    def identifier
      raise "Called abstract method: identifier"
    end

    def apply(params)
      params.each do |key, val|
        if val.is_a? Hash
          target = self.send(key)
          target.apply(val)
        else
          self.send("#{key}=", val)
        end
      end
    end

    def method_missing(method, *args)
      logger.debug "Unknown method #{method} for #{self}."
    end
  end
end
