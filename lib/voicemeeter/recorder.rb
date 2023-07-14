require_relative "iremote"
require_relative "meta"
require_relative "mixins"
require_relative "errors"

require "date"
require "easy_logging"

module Voicemeeter
  module Recorder
    module FileTypeEnum
      WAV = 1
      AIFF = 2
      BWF = 3
      MP3 = 100
    end

    class Recorder < IRemote
      include EasyLogging
      include Mixins::Outputs

      attr_reader :mode, :armstrip, :armbus

      def initialize(remote)
        super
        make_action_method :play, :stop, :pause, :replay, :record, :ff, :rew
        make_accessor_int :bitresolution, :channel, :kbps
        make_accessor_float :gain

        @mode = RecorderMode.new(self)
        @armstrip = (0...remote.kind.num_strip).map { |j| RecorderArmStrip.new(remote, j) }
        @armbus = (0...remote.kind.num_bus).map { |j| RecorderArmBus.new(remote, j) }
      end

      def identifier
        :recorder
      end

      def load(filepath)
        setter("load", filepath)
      end

      def goto(timestr)
        if !(timestr =~ /^(2[0-3]|[01]?[0-9]):([0-5]?[0-9]):([0-5]?[0-9])$/)
          logger.error("goto got: '#{timestr}', but expects a time string in the format 'hh:mm:ss'")
          return
        end
        dt = DateTime.parse(timestr)
        seconds = dt.hour * 3600 + dt.min * 60 + dt.second
        setter("goto", seconds)
      end

      def filetype(val)
        opts = {wav: FileTypeEnum::WAV, aiff: FileTypeEnum::AIFF, bwf: FileTypeEnum::BWF, mp3: FileTypeEnum::MP3}
        setter("filetype", opts[val])
      end
    end

    class RecorderMode < IRemote
      def initialize(remote)
        super
        make_accessor_bool :recbus, :playonload, :loop, :multitrack
      end

      def identifier
        "recorder.mode"
      end
    end
  end

  class RecorderArmChannel < IRemote
    def initialize(remote, j)
      super(remote)
      @j = j
    end

    def set
      setter("", val && 1 || 0)
    end
  end

  class RecorderArmStrip < RecorderArmChannel
    def identifier
      "recorder.armstrip[#{@j}]"
    end
  end

  class RecorderArmBus < RecorderArmChannel
    def identifier
      "recorder.armbus[#{@j}]"
    end
  end
end
