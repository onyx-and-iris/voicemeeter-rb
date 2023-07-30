require "yaml"
require "pathname"

require_relative "kinds"
require_relative "logger"
require_relative "errors"

module Voicemeeter
  module Configs
    private

    class Loader
      include Logging

      attr_reader :configs

      def initialize(kind)
        @kind = kind
        @configs = Hash.new do |hash, key|
          raise Errors::VMError.new "unknown config #{key}. known configs: #{hash.keys}"
        end
        @yml_reader = FileReader.new(self, kind)
      end

      def to_s
        "Loader #{@kind}"
      end

      private

      def build_reset_profile
        aouts = (0...@kind.phys_out).to_h { |i| ["A#{i + 1}".to_sym, false] }
        bouts = (0...@kind.virt_out).to_h { |i| ["B#{i + 1}".to_sym, false] }
        strip_bools = %i[mute mono solo].to_h { |param| [param, false] }
        gain = [:gain].to_h { |param| [param, 0.0] }

        phys_float =
          %i[comp gate denoiser].to_h { |param| [param, {knob: 0.0}] }
        eq = [:eq].to_h { |param| [param, {on: false}] }

        overrides = {B1: true}
        # physical strip params
        phys_strip =
          (0...@kind.phys_in).to_h do |i|
            [
              "strip-#{i}".to_sym,
              {**aouts, **bouts, **strip_bools, **gain, **phys_float, **eq, **overrides}
            ]
          end

        overrides = {A1: true}
        # virtual strip params
        virt_strip =
          (@kind.phys_in...@kind.phys_in + @kind.virt_in).to_h do |i|
            [
              "strip-#{i}".to_sym,
              {**aouts, **bouts, **strip_bools, **gain, **overrides}
            ]
          end

        bus_bools = %i[mute mono].to_h { |param| [param, false] }
        bus =
          (0...@kind.num_bus).to_h do |i|
            ["bus-#{i}".to_sym, {**bus_bools, **gain, **eq}]
          end

        {**phys_strip, **virt_strip, **bus}
      end

      def read_from_yml = @yml_reader.read

      public

      def run
        logger.debug "Running #{self}"
        configs[:reset] = build_reset_profile
        read_from_yml
        self
      end
    end

    class FileReader
      include Logging

      def initialize(loader, kind)
        @loader = loader
        @kind = kind
        @configpaths = [
          Pathname.getwd.join("configs", kind.name.to_s),
          Pathname.new(Dir.home).join(".config", "voicemeeter-rb", kind.name.to_s),
          Pathname.new(Dir.home).join("Documents", "Voicemeeter", "configs", kind.name.to_s)
        ]
      end

      def read
        @configpaths.each do |configpath|
          if configpath.exist?
            logger.debug "checking #{configpath} for configs"
            filepaths = configpath.glob("*.yml")
            filepaths.each do |filepath|
              register(filepath)
            end
          end
        end
      end

      private

      def register(filepath)
        filename = (filepath.basename.sub_ext "").to_s.to_sym
        if @loader.configs.key? filename
          logger.debug "config with name '#{filename}' already in memory, skipping..."
          return
        end

        @loader.configs[filename] = YAML.load_file(
          filepath,
          symbolize_names: true
        )
        logger.info "#{@kind.name}/#{filename} loaded into memory"
      end
    end

    public

    def get(kind_id)
      unless defined? @loaders
        @loaders = Kinds::ALL.to_h { |kind| [kind.name, Loader.new(kind).run] }
      end
      @loaders[kind_id].configs
    end

    module_function :get
  end
end
