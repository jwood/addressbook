module Htpasswd
  module Acls
    class Base
      delegate :logger, :to=>"ActionController::Base"

      @@entries = {}

      class << self
        def [](name)
          name = name.to_s.classify
          @@entries[name] or raise UnknownAccessControl, name
        end

        def register(klass)
          @@entries[klass.name.demodulize.classify] = klass
        end
      end

      def initialize(options)
        @options = options
      end

      def user
        @options[:user]
      end

      def pass
        @options[:pass]
      end

      def type
        @options[:type]
      end

      def authorized?(scheme)
        authorize_type(scheme) && authorize_user(scheme) && authorize_pass(scheme) && scheme.user
      end

      def authorize_type(scheme)
        scheme.authorize_type(type)
      end

      def authorize_user(scheme)
        scheme.authorize_user(user)
      end

      def authorize_pass(scheme)
        scheme.authorize_pass(pass)
      end

      register self
    end

    class CompositeBase < Base
      delegate :each, :<<, :to=>"@entries"

      def initialize(*args)
        @entries = []
        initialize_composite(*args)
      end

      def initialize_composite(*args)
        raise NotImplementedError
      end

      def authorized?(scheme)
        each do |entry|
          if user = entry.authorized?(scheme)
            return user
          end
        end
        return false
      end
    end
  end
end
