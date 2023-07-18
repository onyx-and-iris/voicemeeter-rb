require_relative "../../lib/voicemeeter"

class Main
  GAINLAYER = 0

  def initialize(vm)
    @vm = vm
    @vm.callback.register(self)
  end

  def run
    puts "press <Enter> to quit"
    loop { exit if gets.chomp.empty? }
  end

  def on_update(event)
    if event == "midi"
      current = @vm.midi.current
      midi_handler(current, @vm.midi.get(current))
    end
  end

  def midi_handler(i, val)
    if i.between?(1, 8)
      @vm.strip[i - 1].gainlayer[GAINLAYER].gain = (val * 72 / 127) - 60
    end
  end
end


if $0 == __FILE__
  Voicemeeter::Remote.new(:potato, midi: true).run do |vm|
    Main.new(vm).run
  end
end
