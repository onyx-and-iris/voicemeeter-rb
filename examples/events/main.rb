require_relative "../../lib/voicemeeter"
require "easy_logging"

EasyLogging.level = Logger::DEBUG

class Main
  def initialize
    @vm = Voicemeeter::Remote.new(:potato, pdirty: true, ldirty: true)
    @vm.register(method(:on_pdirty), method(:on_ldirty))
  end

  def run
    @vm.run { exit if gets.chomp.empty? }
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
      puts "#{bus} #{bus.levels.all}" if bus.levels.isdirty?
    end
  end
end

Main.new.run if $0 == __FILE__
