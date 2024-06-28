module Voicemeeter
  module Util
    module CoreExtensions
      refine String do
        def snakecase
          gsub(/([A-Z]+)([A-Z][a-z])/, '\1_\2')
            .gsub(/([a-z\d])([A-Z])/, '\1_\2')
            .tr("-", "_")
            .gsub(/\s/, "_")
            .gsub(/__+/, "_")
            .downcase
        end

        def camelcase
          self if self !~ /_/ && self =~ /[A-Z]+.*/
          split("_").map(&:capitalize).join
        end
      end
    end

    module Timeout
      def login
        super

        err = nil
        start = Time.now
        begin
          sleep 0.1
          logger.info "Successfully logged into #{self} version #{version}"
          logger.debug "login time: #{(Time.now - start).round(2)}"
          err = nil
        rescue Errors::VMCAPIError => e
          err = e
          retry if Time.now < start + @login_timeout
        end
        raise Errors::VMError.new "Timeout logging into the api" if err
        clear_dirty
      end
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
