module Htpasswd
  module Acls
    class Plain < Base
      def authorize_pass(scheme)
        pass == scheme.pass or
          raise IncorrectPassword
      end
      register self
    end
  end
end
