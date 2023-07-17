require "minitest/autorun"

require_relative "../lib/voicemeeter"

class Test
  @vm = Voicemeeter::Remote.new([:basic, :banana, :potato].sample)
  @vm.login
  puts "Running #{@vm.kind.name} tests"

  def self.vm
    @vm
  end

  TestMap = Data.define(:name, :phys_in, :virt_in, :phys_out, :virt_out, :button_lower, :button_higher)

  @data = TestMap.new(@vm.kind.name, @vm.kind.phys_in - 1, @vm.kind.virt_in - 1, @vm.kind.phys_out - 1, @vm.kind.virt_out - 1, 0, 79)

  def self.data
    @data
  end

  Minitest.after_run { @vm.logout }
end
