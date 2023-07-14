require_relative "iremote"
require_relative "meta"

module Voicemeeter
  class Device
    def initialize(remote)
      @remote = remote
    end

    def to_s
      "#{self.class.name.split("::").last}#{@index}#{@remote.kind}"
    end

    def getter(**kwargs)
      return @remote.get_num_devices(kwargs[:direction]) if kwargs[:index].nil?

      vals = @remote.get_device_description(kwargs[:index], kwargs[:direction])
      types = {1 => "mme", 3 => "wdm", 4 => "ks", 5 => "asio"}
      {name: vals[0], type: types[vals[1]], id: vals[2]}
    end

    def ins = getter(direction: :in)

    def outs = getter(direction: :out)

    def input(i) = getter(index: i, direction: :in)

    def output(i) = getter(index: i, direction: :out)
  end
end
