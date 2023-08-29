module Voicemeeter
  module Util
    module String
      def snakecase(s)
        s.gsub(/([A-Z]+)([A-Z][a-z])/, '\1_\2')
          .gsub(/([a-z\d])([A-Z])/, '\1_\2')
          .tr("-", "_")
          .gsub(/\s/, "_")
          .gsub(/__+/, "_")
          .downcase
      end

      def camelcase(s)
        s if s !~ /_/ && s =~ /[A-Z]+.*/
        s.split("_").map { |e| e.capitalize }.join
      end

      module_function :snakecase, :camelcase
    end

    module Cache
      def get(name, is_string = false)
        return cache.delete(name) if cache.key? name
        clear_dirty if @sync
        super
      end

      def get_buttonstatus(id, mode)
        return cache.delete("mb_#{id}_#{mode}") if cache.key? "mb_#{id}_#{mode}"
        clear_dirty if @sync
        super
      end
    end
  end
end
