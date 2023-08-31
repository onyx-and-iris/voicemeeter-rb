module Voicemeeter
  # Common interface with the base Remote class.
  module IRemote
    include Logging

    def initialize(remote, i = nil)
      @remote = remote
      @index = i
    end

    def to_s
      "#{self.class.name.split("::").last}#{@index}#{@remote.kind}"
    end

    private

    def getter(param, is_string = false)
      logger.debug "getter: #{_cmd(param)}"
      @remote.get(_cmd(param), is_string)
    end

    def setter(param, value)
      logger.debug "setter: #{_cmd(param)}=#{value}"
      @remote.set(_cmd(param), value)
    end

    def _cmd(param)
      param.empty? ? identifier : "#{identifier}.#{param}"
    end

    def identifier
      raise "Called abstract method: identifier"
    end

    public

    def apply(params)
      params.each do |key, val|
        if val.is_a? Hash
          target = pulic_send(key)
          target.apply(val)
        elsif key == :mode
          mode.pulic_send("#{val}=", true)
        else
          pulic_send("#{key}=", val)
        end
      end
    end
  end
end
