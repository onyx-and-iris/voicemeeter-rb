require_relative "../../lib/voicemeeter"

class Main
  def initialize(vm)
    @vm = vm
    @vm.callback.register(method(:on_pdirty), method(:on_mdirty), method(:on_midi), method(:on_ldirty))
  end

  def run
    exit if gets.chomp.empty?
  end

  def on_pdirty
    puts "pdirty"
  end

  def on_mdirty
    puts "mdirty"
  end

  def on_midi
    current = @vm.midi.current
    puts "Value of midi button #{current}: #{@vm.midi.get(current)}"
  end

  def on_ldirty
    @vm.bus.each do |bus|
      puts "#{bus} #{bus.levels.all.join(" ")}" if bus.levels.isdirty?
    end
  end
end

if $0 == __FILE__
  Voicemeeter::Remote.new(:potato, pdirty: true, mdirty: true, midi: true, ldirty: true).run do |vm|
    Main.new(vm).run
  end
end
