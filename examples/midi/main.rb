require_relative "../../lib/voicemeeter"

class Main
  GAINLAYER = 0

  def initialize(vm)
    @vm = vm
    @vm.on :midi do
      current = @vm.midi.current
      handler(current, @vm.midi.get(current))
    end
  end

  def run
    puts "press <Enter> to quit"
    loop { break if gets.chomp.empty? }
  end

  def handler(i, val)
    if i.between?(0, 7)
      @vm.strip[i].gainlayer[GAINLAYER].gain = (val * 72 / 127) - 60
    end
  end
end


if $PROGRAM_NAME == __FILE__
  Voicemeeter::Remote.new(:potato, midi: true).run do |vm|
    Main.new(vm).run
  end
end
