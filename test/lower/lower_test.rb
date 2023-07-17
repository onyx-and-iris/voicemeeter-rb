require_relative "../minitest_helper"

class SetGetParamTest < Minitest::Test
  def test_it_sets_and_gets_float_parameter
    Test.vm.set("Fx.Reverb.On", 1)
    assert_equal(1, Test.vm.get("Fx.Reverb.On"))
  end
end

class SetGetButtonTest < Minitest::Test
  def test_it_sets_and_gets_macrobutton_parameter
    Test.vm.set_buttonstatus(0, 3, 1)   # button0, trigger, true
    assert_equal(1, Test.vm.get_buttonstatus(0, 3))
  end
end
