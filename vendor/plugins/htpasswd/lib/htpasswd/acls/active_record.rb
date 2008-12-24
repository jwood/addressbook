module Htpasswd
  module Acls
    class ActiveRecord < Base
      def authorize_user(scheme)
        active_record.send("find_by_%s" % (@options[:user] || :username), scheme.user)
      end

      def authorize_pass(scheme)
        obj = active_record.send("find_by_%s" % (@options[:user] || :username), scheme.user)
        scheme.authorize_pass(obj[@options[:pass] || :password])
      rescue
        raise IncorrectPassword
      end

      protected
      def active_record
        @active_record ||= @options[:class].to_s.classify.constantize
      rescue
        raise ConfigurationError, "invalid active_record class name: '%s'" % @options[:class].to_s
      end

      register self
    end
  end
end
