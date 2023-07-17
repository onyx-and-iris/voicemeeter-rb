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
  [-8.2, 3.2].each do |val|
    define_method("test_it_sets_and_gets_bus_#{Test.data.phys_out}_gain_#{val}") do
      Test.vm.bus[Test.data.phys_out].gain = val
      assert_equal(val, Test.vm.bus[Test.data.phys_out].gain)
    end
  end
end

class VbanTest < Minitest::Test
  ["test0", "test1"].each do |val|
    define_method("test_it_sets_and_gets_vban_#{Test.data.vban_in}_name_#{val}") do
      Test.vm.vban.instream[Test.data.vban_in].name = val
      assert_equal(val, Test.vm.vban.instream[Test.data.vban_in].name)
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
