module Htpasswd
  module Acls
    class Digest < Base
      def authorize_type(scheme)
        scheme.is_a?(Auths::Digest)
      end
      register self
    end
  end
end
