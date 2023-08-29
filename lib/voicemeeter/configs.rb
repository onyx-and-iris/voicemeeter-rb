module Voicemeeter
  module Configs
    class TOMLConfBuilder
      def self.run(kind)
        aouts = (0...kind.phys_out).to_h { |i| [:"A#{i + 1}", false] }
        bouts = (0...kind.virt_out).to_h { |i| [:"B#{i + 1}", false] }
        strip_bools = %i[mute mono solo].to_h { |param| [param, false] }
        gain = [:gain].to_h { |param| [param, 0.0] }

        phys_float =
          %i[comp gate denoiser].to_h { |param| [param, {knob: 0.0}] }
        eq = [:eq].to_h { |param| [param, {on: false}] }

        overrides = {B1: true}
        phys_strip =
          (0...kind.phys_in).to_h do |i|
            [
              "strip-#{i}".to_sym,
              {**aouts, **bouts, **strip_bools, **gain, **phys_float, **eq, **overrides}
            ]
          end

        overrides = {A1: true}
        virt_strip =
          (kind.phys_in...kind.phys_in + kind.virt_in).to_h do |i|
            [
              :"strip-#{i}",
              {**aouts, **bouts, **strip_bools, **gain, **overrides}
            ]
          end

        bus_bools = %i[mute mono].to_h { |param| [param, false] }
        bus =
          (0...kind.num_bus).to_h do |i|
            [:"bus-#{i}", {**bus_bools, **gain, **eq}]
          end

        {**phys_strip, **virt_strip, **bus}
      end
    end

    class FileReader
      include Logging

      def initialize(kind)
        @configpaths = [
          Pathname.getwd.join("configs", kind.name.to_s),
          Pathname.new(Dir.home).join(".config", "voicemeeter-rb", kind.name.to_s),
          Pathname.new(Dir.home).join("Documents", "Voicemeeter", "configs", kind.name.to_s)
        ]
      end

      def each
        @configpaths.each do |configpath|
          if configpath.exist?
            logger.debug "checking #{configpath} for configs"
            filepaths = configpath.glob("*.{yaml,yml}")
            filepaths.each do |filepath|
              @filename = (filepath.basename.sub_ext "").to_s.to_sym

              yield @filename, YAML.load_file(
                filepath,
                symbolize_names: true
              )
            end
          end
        end
      rescue Psych::SyntaxError => e
        logger.error "#{e.class.name}: #{e.message}"
      end
    end

    class Loader
      include Logging

      attr_reader :configs

      def initialize(kind)
        @kind = kind
        @configs = Hash.new do |hash, key|
          raise Errors::VMError.new "unknown config '#{key}'. known configs: #{hash.keys}"
        end
        @filereader = FileReader.new(kind)
      end

      def to_s
        "Loader #{@kind}"
      end

      def run
        logger.debug "Running #{self}"
        configs[:reset] = TOMLConfBuilder.run(@kind)
        @filereader.each(&method(:register))
        self
      end

      private def register(identifier, data)
        if configs.key? identifier
          logger.debug "config with name '#{identifier}' already in memory, skipping..."
          return
        end

        configs[identifier] = data
        logger.info "#{@kind.name}/#{identifier} loaded into memory"
      end
    end

    def get(kind_id)
      unless defined? @loaders
        @loaders = Kinds::ALL.to_h { |kind| [kind.name, Loader.new(kind).run] }
      end
      @loaders[kind_id].configs
    end

    module_function :get
  end
end
