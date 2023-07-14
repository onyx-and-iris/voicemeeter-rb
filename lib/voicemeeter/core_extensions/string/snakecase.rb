module Voicemeeter
  module Ext
    module String
      module SnakeCase
        class ::String
          def snakecase
            gsub(/([A-Z]+)([A-Z][a-z])/, '\1_\2')
              .gsub(/([a-z\d])([A-Z])/, '\1_\2')
              .tr("-", "_")
              .gsub(/\s/, "_")
              .gsub(/__+/, "_")
              .downcase
          end
        end
      end
    end
  end
end
