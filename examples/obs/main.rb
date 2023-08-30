require_relative "../../lib/voicemeeter"
require "obsws"
require "yaml"
require "pathname"

class Main
  def initialize(vm, **kwargs)
    @vm = vm
    @obsws = OBSWS::Events::Client.new(**kwargs)

    @obsws.on :current_program_scene_changed do |data|
      scene = data.scene_name
      puts "Switched to scene #{scene}"
      if respond_to?("on_#{scene.downcase}")
        send("on_#{scene.downcase}")
      end
    end

    @obsws.on :exit_started do |data|
      puts "OBS closing!"
      @obsws.close
      @running = false
    end
  end

  def run
    @running = true
    sleep(0.1) while @running
  end

  def on_start
    @vm.strip[0].mute = true
    @vm.strip[1].B1 = true
    @vm.strip[2].B2 = true
  end

  def on_live
    @vm.strip[0].mute = false
    @vm.strip[7].A3 = true
    @vm.strip[7].fadeto(-6, 500)
    @vm.vban.instream[0].on = true
  end

  def on_brb
    @vm.strip[0].mute = false
    @vm.strip[5].A1 = true
    @vm.strip[5].A2 = true
    @vm.strip[7].fadeto(0, 500)
  end

  def on_end
    @vm.apply({"strip-0" => {mute: true}, "vban-instream-0" => {on: false}})
  end
end

def conn_from_yml
  pn = Pathname.new(__dir__).join("config.yaml")
  YAML.load_file(pn, symbolize_names: true)[:connection]
end

if $PROGRAM_NAME == __FILE__
  Voicemeeter::Remote.new(:potato).run do |vm|
    Main.new(vm, **conn_from_yml).run
  end
end
