require "yaml"
require "easy_logging"
require "pathname"

require_relative "kinds"

module Voicemeeter
  module Configs
    private

    class Loader
      include EasyLogging

      attr_reader :configs

      def initialize(kind)
        @kind = kind
        @configs = Hash.new
      end

      def to_s
        "Loader #{@kind}"
      end

      protected

      #stree-ignore
      def build_reset_profile
        aouts = (0...@kind.phys_out).to_h { |i| ["A#{i + 1}", false] }
        bouts = (0...@kind.virt_out).to_h { |i| ["B#{i + 1}", false] }
        strip_bools = %w[mute mono solo].to_h { |param| [param, false] }
        gain = ["gain"].to_h { |param| [param, 0.0] }

        phys_float =
          %w[comp gate denoiser].to_h { |param| [param, { knob: 0.0 }] }
        eq = ["eq"].to_h { |param| [param, { on: false }] }

        overrides = { "B1" => true }

        # physical strip params
        phys_strip =
          (0...@kind.phys_in).to_h do |i|
            [
              "strip-#{i}",
              {**aouts,**bouts,**strip_bools,**gain,**phys_float,**eq,**overrides}
            ]
          end

        overrides = { "A1" => true }
        # virtual strip params
        virt_strip =
          (@kind.phys_in...@kind.phys_in + @kind.virt_in).to_h do |i|
            [
              "strip-#{i}",
              { **aouts, **bouts, **strip_bools, **gain, **overrides }
            ]
          end

        bus_bools = %w[mute mono].to_h { |param| [param, false] }
        bus =
          (0...@kind.num_bus).to_h do |i|
            ["bus-#{i}", { **bus_bools, **gain, **eq }]
          end
        { **phys_strip, **virt_strip, **bus }
      end

      def read_from_yml
        #stree-ignore
        filepaths = [
          Pathname.getwd.join("configs", @kind.name.to_s),
          Pathname.new(Dir.home).join(".config", "voicemeeter-rb", @kind.name.to_s),
          Pathname.new(Dir.home).join("Documents", "Voicemeeter", "configs", @kind.name.to_s)
        ]
        filepaths.each do |pn|
          if pn.exist?
            logger.debug "checking #{pn} for configs"
            configs = pn.glob("*.yml")
            configs.each do |config|
              filename = (config.basename.sub_ext "").to_s.to_sym
              if @configs.key? filename
                logger.debug "config with name '#{filename}' already in memory, skipping..."
                next
              end
              @configs[filename] = YAML.load_file(config)
              logger.info "#{@kind.name}/#{filename} loaded into memory"
            end
          end
        end
      end

      public

      def build
        logger.debug "Running #{self}"
        @configs[:reset] = build_reset_profile
        read_from_yml
      end
    end

    public

    def get(kind_id)
      if @loaders.nil?
        @loaders = Kinds::ALL.to_h { |kind| [kind.name, Loader.new(kind)] }
        @loaders.each { |name, loader| loader.build }
      end
      @loaders[kind_id].configs
    end

    module_function :get
  end
end
