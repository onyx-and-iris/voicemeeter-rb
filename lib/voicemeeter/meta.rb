module Voicemeeter
  module MetaFunctions
    private

    # Accessor methods
    def attr_accessor_bool(*params)
      params.each do |param|
        define_method(param) { getter(param).to_i == 1 }

        define_method("#{param}=") do |value|
          setter(param, value && 1 || 0)
        end
      end
    end

    def attr_accessor_string(*params)
      params.each do |param|
        define_method(param) { getter(param, true) }

        define_method("#{param}=") { |value| setter(param, value) }
      end
    end

    def attr_accessor_int(*params)
      params.each do |param|
        define_method(param) { getter(param).to_i }

        define_method("#{param}=") { |value| setter(param, value) }
      end
    end

    def attr_accessor_float(*params)
      params.each do |param|
        define_method(param) { getter(param) }

        define_method("#{param}=") { |value| setter(param, value) }
      end
    end

    # reader methods
    def attr_reader_string(*params)
      params.each do |param|
        define_method(param) { getter(param, true) }
      end
    end

    def attr_reader_int(*params)
      params.each do |param|
        define_method(param) { getter(param).to_i }
      end
    end

    # writer methods
    def attr_writer_bool(*params)
      params.each do |param|
        define_method("#{param}=") do |value|
          setter(param, value && 1 || 0)
        end
      end
    end

    def attr_writer_string(*params)
      params.each do |param|
        define_method("#{param}=") { |value| setter(param, value) }
      end
    end

    # methods for performing certain actions as opposed to setting values
    def attr_action_method(*params)
      params.each do |param|
        define_method(param) { setter(param, 1) }
      end
    end
  end
end
