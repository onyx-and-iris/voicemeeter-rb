require_relative "../../lib/voicemeeter"

class Main
  def initialize(vm)
    @vm = vm

    @vm.on :pdirty do
      puts "pdirty"
    end

    @vm.on :mdirty do
      puts "mdirty"
    end

    @vm.on :midi do
      current = @vm.midi.current
      puts "Value of midi input #{current}: #{@vm.midi.get(current)}"
    end

    @vm.on :ldirty do
      @vm.bus.each do |bus|
        puts "#{bus} #{bus.levels.all.join(" ")}" if bus.levels.isdirty?
      end
    end
  end

  def run
    puts "press <Enter> to quit"
    loop { break if gets.chomp.empty? }
  end
end

if $PROGRAM_NAME == __FILE__
  Voicemeeter::Remote
    .new(:potato, pdirty: true, mdirty: true, midi: true, ldirty: true)
    .run do |vm|
    Main.new(vm).run
  end
end
