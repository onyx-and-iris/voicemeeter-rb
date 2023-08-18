require_relative "minitest_helper"
require "voicemeeter"

class CAPIErrorTest < Minitest::Test
  def test_it_raises_a_capierror_on_unknown_parameter
    e = assert_raises(Voicemeeter::Errors::VMCAPIError) { Test.vm.set("Unknown.Parameter", 1) }
    assert_equal("VBVMR_SetParameterFloat", e.fn_name)
    assert_equal(-3, e.code)
  end
end

class InvalidKindTest < MiniTest::Test
  def test_it_raises_a_vmerror_on_invalid_kind
    e = assert_raises(Voicemeeter::Errors::VMError) { Voicemeeter::Remote.new("unknown_kind") }
    assert_equal("unknown Voicemeeter kind 'unknown_kind'", e.message)
  end
end

class UnknownConfigTest < MiniTest::Test
  def test_it_raises_a_vmerror_on_unknown_config_name
    e = assert_raises(Voicemeeter::Errors::VMError) { Test.vm.apply_config(:unknown) }
    assert_equal("unknown config 'unknown'. known configs: #{Test.vm.configs.keys}", e.message)
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
    assert_equal("invalid config key 'unknown-0'", e.message)
  end
end
