require_relative "minitest_helper"
require_relative "../lib/voicemeeter"

class CAPIErrorTest < Minitest::Test
  def test_it_raises_an_unknown_parameter_error
    e = assert_raises(Voicemeeter::Errors::VMCAPIError) { Test.vm.set("Unknown.Parameter", 1) }
    assert_equal(e.code, -3)
  end
end

class InvalidKindTest < MiniTest::Test
  def test_it_raises_an_invalid_kind_error
    assert_raises(Voicemeeter::Errors::VMError) { Voicemeeter::Remote.new("unknown_kind") }
  end
end

class UnknownConfigTest < MiniTest::Test
  def test_it_raises_an_unknown_config_error
    assert_raises(Voicemeeter::Errors::VMError) { Test.vm.apply_config(:unknown) }
  end
end
