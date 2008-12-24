module Htpasswd
  module Acls
    class Crypted < Base
      def authorize_pass(scheme)
        pass == scheme.pass.crypt(pass) or
          raise IncorrectPassword
      end
      register self
    end
  end
end
