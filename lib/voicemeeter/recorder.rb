module Voicemeeter
  module Recorder
    module FileTypeEnum
      WAV = 1
      AIFF = 2
      BWF = 3
      MP3 = 100
    end

    # Base class for Recorder
    class Base
      include IRemote
      include Mixins::Outputs
      extend MetaFunctions

      attr_reader :mode, :armstrip, :armbus
      attr_action_method :play, :stop, :pause, :replay, :record, :ff, :rew
      attr_accessor_int :bitresolution, :channel, :kbps
      attr_accessor_float :gain

      def initialize(remote)
        super
        make_attr_outputs(*remote.kind.outs)

        @mode = RecorderMode.new(remote)
        @armstrip = (0...remote.kind.num_strip).map { RecorderArmStrip.new(remote, _1) }
        @armbus = (0...remote.kind.num_bus).map { RecorderArmBus.new(remote, _1) }
      end

      def identifier
        :recorder
      end

      def load(filepath)
        setter("load", filepath)
      end

      def goto(timestr)
        unless /^(2[0-3]|[01]?[0-9]):([0-5]?[0-9]):([0-5]?[0-9])$/.match?(timestr)
          logger.error "goto got: '#{timestr}', but expects a time string in the format 'hh:mm:ss'"
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

    class RecorderMode
      include IRemote
      extend MetaFunctions

      attr_accessor_bool :recbus, :playonload, :loop, :multitrack

      def identifier
        "recorder.mode"
      end
    end

    class RecorderArmChannel
      include IRemote

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
end
