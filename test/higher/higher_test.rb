require_relative "../minitest_helper"

class StripTest < Minitest::Test
  [false, true].each do |val|
    define_method("test_it_sets_and_gets_strip_#{Test.data.phys_in}_mute_#{val}") do
      Test.vm.strip[Test.data.phys_in].mute = val
      assert_equal(val, Test.vm.strip[Test.data.phys_in].mute)
    end
  end
end

class BusTest < Minitest::Test
  [false, true].each do |val|
    define_method("test_it_sets_and_gets_bus_#{Test.data.phys_out}_mute_#{val}") do
      Test.vm.bus[Test.data.phys_out].mute = val
      assert_equal(val, Test.vm.bus[Test.data.phys_out].mute)
    end
  end
end

class VbanTest < Minitest::Test
  [false, true].each do |val|
    define_method("test_it_sets_and_gets_vban_#{Test.data.phys_in}_on_#{val}") do
      Test.vm.vban.instream[0].on = val
      assert_equal(val, Test.vm.vban.instream[0].on)
    end
  end
end

class ButtonTest < Minitest::Test
  [false, true].each do |val|
    define_method("test_it_sets_and_gets_button_#{Test.data.button_lower}_stateonly_#{val}") do
      Test.vm.button[Test.data.button_lower].stateonly = val
      assert_equal(val, Test.vm.button[Test.data.button_lower].stateonly)
    end
  end
end

class RecorderTest < Minitest::Test
  if Test.data.name != :basic
    [false, true].each do |val|
      define_method("test_it_sets_and_gets_recorder_mode_loop_#{val}") do
        Test.vm.recorder.mode.loop = val
        assert_equal(val, Test.vm.recorder.mode.loop)
      end
    end
  end
end
