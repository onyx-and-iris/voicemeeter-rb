require_relative "minitest_helper"
require "voicemeeter"

class CAPIErrorTest < Minitest::Test
  def test_it_raises_an_unknown_parameter_error
    e = assert_raises(Voicemeeter::Errors::VMCAPIError) { Test.vm.set("Unknown.Parameter", 1) }
    assert_equal(e.fn_name, "VBVMR_SetParameterFloat")
    assert_equal(e.code, -3)
  end
end

class InvalidKindTest < MiniTest::Test
  def test_it_raises_an_invalid_kind_error
    e = assert_raises(Voicemeeter::Errors::VMError) { Voicemeeter::Remote.new("unknown_kind") }
    assert_equal(e.message, "unknown Voicemeeter kind unknown_kind")
  end
end

class UnknownConfigTest < MiniTest::Test
  def test_it_raises_an_unknown_config_error
    e = assert_raises(Voicemeeter::Errors::VMError) { Test.vm.apply_config(:unknown) }
    assert_equal(e.message, "unknown config unknown. known configs: #{Test.vm.configs.keys}")
  end
end
