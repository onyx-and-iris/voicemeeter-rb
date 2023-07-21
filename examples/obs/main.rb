require_relative "../../lib/voicemeeter"
require "obsws"
require "yaml"
require "pathname"

class Main
  attr_reader :running

  def initialize(vm, **kwargs)
    @vm = vm
    @obsws = OBSWS::Events::Client.new(**kwargs)
    @obsws.add_observer(self)
    @running = true
  end

  def run
    sleep(0.1) while running
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

  def on_current_program_scene_changed(data)
    scene = data.scene_name
    puts "Switched to scene #{scene}"
    send("on_#{scene.downcase}")
  end

  def on_exit_started
    puts "OBS closing!"
    @obsws.close
    @running = false
  end
end

def conn_from_yml
  YAML.load_file("config.yaml", symbolize_names: true)[:connection]
end


if $PROGRAM_NAME == __FILE__
  Voicemeeter::Remote.new(:potato).run do |vm|
    Main.new(vm, **conn_from_yml).run
  end
end
