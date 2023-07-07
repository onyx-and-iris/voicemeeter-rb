module Voicemeeter
  module Meta_Functions
    # Accessor methods
    def make_accessor_bool(*params)
      params.each do |param|
        define_singleton_method(param) { self.getter(param).to_i == 1 }
        define_singleton_method("#{param}=") do |value|
          self.setter(param, value && 1 || 0)
        end
      end
    end

    def make_accessor_string(*params)
      params.each do |param|
        define_singleton_method(param) { self.getter(param, true) }

        define_singleton_method("#{param}=") do |value|
          self.setter(param, value)
        end
      end
    end

    def make_accessor_int(*params)
      params.each do |param|
        define_singleton_method("#{param}") do
          return self.getter("#{param}").to_i
        end

        define_singleton_method("#{param}=") do |value|
          self.setter("#{param}", value)
        end
      end
    end

    def make_accessor_float(*params)
      params.each do |param|
        define_singleton_method(param) { self.getter(param) }

        define_singleton_method("#{param}=") do |value|
          self.setter(param, value)
        end
      end
    end

    # reader methods
    def make_reader_string(*params)
      params.each do |param|
        define_singleton_method(param) { self.getter(param, true) }
      end
    end

    def make_reader_int(*params)
      params.each do |param|
        define_singleton_method(param) { self.getter(param).to_i }
      end
    end

    # writer methods
    def make_writer_string(*params)
      params.each do |param|
        define_singleton_method("#{param}=") do |value|
          self.setter(param, value)
        end
      end
    end
  end
end
