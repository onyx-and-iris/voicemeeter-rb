module Voicemeeter
  module Ext
    module String
      module CamelCase
        class ::String
          def camelcase
            self if self !~ /_/ && self =~ /[A-Z]+.*/
            split("_").map { |e| e.capitalize }.join
          end
        end
      end
    end
  end
end
