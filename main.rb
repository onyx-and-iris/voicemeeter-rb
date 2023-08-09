require "voicemeeter"

class Main
  def run
    Voicemeeter::Remote.new(:banana).run do |vm|
      vm.strip[0].label = "podmic"
      vm.strip[0].mute = true
      puts "strip 0 #{vm.strip[0].label} mute was set to #{vm.strip[0].mute}"

      vm.bus[3].gain = -6.3
      vm.bus[4].eq.on = true
      info = [
        "bus 3 gain has been set to #{vm.bus[3].gain}",
        "bus 4 eq has been set to #{vm.bus[4].eq.on}"
      ]
      puts info
    end
  end
end

Main.new.run if $PROGRAM_NAME == __FILE__
