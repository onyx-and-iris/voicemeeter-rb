require_relative "minitest_helper"

class BasicFactoryTest < Minitest::Test
  if Test.data.name == :basic
    define_method("test_it_tests_#{Test.data.name}_kind_factory") do
      %i[strip bus button vban command device option].each do
        assert(Test.vm.respond_to?(_1))
      end
    end

    define_method("test_it_tests_#{Test.data.name}_kind_factory_steps") do
      assert(Test.vm.strip.length == 3)
      assert(Test.vm.bus.length == 2)
      assert(Test.vm.button.length == 80)
      assert(Test.vm.vban.instream.length == 6 && Test.vm.vban.outstream.length == 5)
    end
  end
end

class BananaFactoryTest < Minitest::Test
  if Test.data.name == :banana
    define_method("test_it_tests_#{Test.data.name}_kind_factory") do
      %i[strip bus button vban command device option recorder patch].each do
        assert(Test.vm.respond_to?(_1))
      end
    end

    define_method("test_it_tests_#{Test.data.name}_kind_factory_steps") do
      assert(Test.vm.strip.length == 5)
      assert(Test.vm.bus.length == 5)
      assert(Test.vm.button.length == 80)
      assert(Test.vm.vban.instream.length == 10 && Test.vm.vban.outstream.length == 9)
    end
  end
end

class PotatoFactoryTest < Minitest::Test
  if Test.data.name == :potato
    define_method("test_it_tests_#{Test.data.name}_kind_factory") do
      %i[strip bus button vban command device option recorder patch fx].each do
        assert(Test.vm.respond_to?(_1))
      end
    end

    define_method("test_it_tests_#{Test.data.name}_kind_factory_steps") do
      assert(Test.vm.strip.length == 8)
      assert(Test.vm.bus.length == 8)
      assert(Test.vm.button.length == 80)
      assert(Test.vm.vban.instream.length == 10 && Test.vm.vban.outstream.length == 9)
    end
  end
end
