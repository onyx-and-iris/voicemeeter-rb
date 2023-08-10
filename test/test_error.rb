require_relative "minitest_helper"
require "voicemeeter"

class CAPIErrorTest < Minitest::Test
  def test_it_raises_a_capierror_on_unknown_parameter
    e = assert_raises(Voicemeeter::Errors::VMCAPIError) { Test.vm.set("Unknown.Parameter", 1) }
    assert_equal(e.fn_name, "VBVMR_SetParameterFloat")
    assert_equal(e.code, -3)
  end
end

class InvalidKindTest < MiniTest::Test
  def test_it_raises_a_vmerror_on_invalid_kind
    e = assert_raises(Voicemeeter::Errors::VMError) { Voicemeeter::Remote.new("unknown_kind") }
    assert_equal(e.message, "unknown Voicemeeter kind 'unknown_kind'")
  end
end

class UnknownConfigTest < MiniTest::Test
  def test_it_raises_a_vmerror_on_unknown_config_name
    e = assert_raises(Voicemeeter::Errors::VMError) { Test.vm.apply_config(:unknown) }
    assert_equal(e.message, "unknown config 'unknown'. known configs: #{Test.vm.configs.keys}")
  end
end

class UnknownConfigKey < MiniTest::Test
  def test_it_raises_a_keyerror_on_unknown_config_key
    config = {
      "strip-0" => {mute: true, gain: 3.2, A1: true},
      "unknown-0" => {stateonly: true},
      "vban-out-3" => {on: true, bit: 24}
    }
    e = assert_raises(KeyError) { Test.vm.apply(config) }
    assert_equal(e.message, "invalid config key 'unknown-0'")
  end
end
