require "minitest/autorun"
require "voicemeeter"

class Test
  class << self
    attr_reader :vm, :data
  end

  @vm = Voicemeeter::Remote.new(ENV.fetch("KIND", "potato").to_sym)
  vm.login
  puts "Running #{vm.kind.name} tests"

  TestMap = Data.define(:name, :phys_in, :virt_in, :phys_out, :virt_out, :button_lower, :button_higher, :vban_in, :vban_out)

  @data = TestMap.new(
    vm.kind.name,
    vm.kind.phys_in - 1,
    vm.kind.virt_in - 1,
    vm.kind.phys_out - 1,
    vm.kind.virt_out - 1,
    0, 79,
    vm.kind.vban[0] - 1,
    vm.kind.vban[1] - 1
  )

  Minitest.after_run { vm.logout }
end
