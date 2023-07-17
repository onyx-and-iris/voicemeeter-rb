module Voicemeeter
  module Util
    def snakecase(string)
      string.gsub(/([A-Z]+)([A-Z][a-z])/, '\1_\2')
        .gsub(/([a-z\d])([A-Z])/, '\1_\2')
        .tr("-", "_")
        .gsub(/\s/, "_")
        .gsub(/__+/, "_")
        .downcase
    end

    def camelcase(string)
      string if string !~ /_/ && string =~ /[A-Z]+.*/
      string.split("_").map { |e| e.capitalize }.join
    end

    module_function :snakecase, :camelcase
  end
end
