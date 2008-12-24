module Htpasswd
  module Auths
    class Basic < Base
      class << self
        def parse(data)
          user, pass = Base64.decode64(data.to_s).split(':', 2)
          new(:user=>user, :pass=>pass)
        end

        def strength
          10
        end
      end

      def server_header
        %Q|Basic realm="%s"| % realm
      end
    end
    @@schemas["Basic"] = Basic
  end
end
