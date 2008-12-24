module Htpasswd
  module Auths
    @@schemas = {}

    module_function
    def [](auth_scheme)
      @@schemas[auth_scheme.to_s.classify]
    end

    def scheme(controller)
      case controller
      when ActionController::Base
        returning authorization = instantiate(extract_header(controller.request.env)) do
          authorization.set_controller(controller)
        end
      else
        instantiate(controller.to_s)
      end
    end

    def instantiate(header)
      raise HeaderNotFound if header.blank?
      ActionController::Base.logger.debug "Htpasswd accepts authorization header: '#{header}'"
      type, data = header.to_s.split(' ', 2)
      klass = self[type] or raise UnknownSchemeError, type
      klass.parse(data)
    end

    def extract_header(hash)
      [
       'X-HTTP_AUTHORIZATION',          # for Apache/mod_rewrite
       'REDIRECT_X_HTTP_AUTHORIZATION', # for Apache2/mod_rewrite
       'Authorization',                 # for Apace/mod_fastcgi with -pass-header Authorization 
       'HTTP_AUTHORIZATION',            # this is the regular location 
      ].map{|name| hash[name]}.compact.first
    end

    def default_realm
      "Authorization"
    end

    class Base
      delegate :logger, :to=>"ActionController::Base"
      
      class << self
        def parse(data)
          raise NotImplementedError, "subclass responsibility"
        end

        def <=> (other)
          strength <=> other.strength
        end
      end

      attr_accessor :options
      def initialize(options = {})
        @options = options.with_indifferent_access
      end

      # return authorized username or raise exception
      def authorize(entries)
        entries.each do |entry|
          if user = entry.authorized?(self)
            return user
          end
        end
        raise UnknownUserAccount
      end

      def authorize_type(type)
        true
      end

      def authorize_user(user)
        options[:user] == user
      end

      def authorize_pass(pass)
        options[:pass] == pass or raise IncorrectPassword
      end

      def set_controller(controller)
        # nop
      end

      def realm
        options[:realm] || Auths.default_realm
      end

      def scheme
        self.class.name.demodulize
      end

      def user
        options[:user]
      end

      def pass
        options[:pass]
      end

      def random(size = 16, array = nil)
        array ||= (0..9).to_a + ('a'..'f').to_a
        (0...size).map{array[rand(array.size)]}.join
      end
    end
  end
end
