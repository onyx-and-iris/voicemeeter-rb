require "yaml"
require_relative "kinds"
require "easy_logging"

module Voicemeeter
  module Configs
    private

    class Loader
      include EasyLogging

      attr_reader :configs

      def initialize(kind)
        @kind = kind
        @configs = Hash.new
        logger.debug("generated loader for #{kind}")
      end

      protected

      def build_reset_profile(overrides = {})
        aouts = (0...@kind.phys_out).to_h { |i| ["A#{i + 1}", false] }
        bouts = (0...@kind.virt_out).to_h { |i| ["B#{i + 1}", false] }
        bools = %w[mute mono solo].to_h { |param| [param, false] }
        floats = ["gain"].to_h { |param| [param, 0.0] }

        phys_float =
          %w[comp gate denoiser].to_h { |param| [param, { knob: 0.0 }] }
        phys_bool = ["eq"].to_h { |param| [param, { on: false }] }

        # physical strip params
        phys_strip =
          (0...@kind.phys_in).to_h do |i|
            [
              "strip-#{i}",
              { **aouts, **bouts, **bools, **floats, **phys_float, **phys_bool }
            ]
          end
        # virtual strip params
        virt_strip =
          (@kind.phys_in...@kind.phys_in + @kind.virt_in).to_h do |i|
            ["strip-#{i}", { **aouts, **bouts, **bools, **floats }]
          end
        { **phys_strip, **virt_strip }
      end

      public

      def build
        @configs[:reset] = build_reset_profile
      end
    end

    public

    def load
      if @loaders.nil?
        @loaders = Kinds::ALL.to_h { |kind| [kind.name, Loader.new(kind)] }
        @loaders.each { |name, loader| loader.build }
      end
    end

    def get(kind_id)
      @loaders[kind_id].configs
    end

    module_function :get, :load
  end
end
