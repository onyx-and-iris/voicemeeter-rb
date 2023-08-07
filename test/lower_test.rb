require_relative "minitest_helper"

class SetGetParamTest < Minitest::Test
  def test_it_sets_and_gets_float_parameter
    Test.vm.set("Fx.Reverb.On", 1)
    assert_equal(1, Test.vm.get("Fx.Reverb.On"))
  end

  def test_it_sets_and_gets_string_parameter
    Test.vm.set("Strip[0].Label", "strip0name")
    assert_equal("strip0name", Test.vm.get("Strip[0].Label", true))
  end
end

class SetGetButtonTest < Minitest::Test
  def test_it_sets_and_gets_macrobutton_parameter
    Test.vm.set_buttonstatus(0, 3, 1)   # button[0], trigger, true
    assert_equal(1, Test.vm.get_buttonstatus(0, 3))
  end
end
