module Htpasswd
  module Auths
    class Digest < Base
      class << self
        PARAMETER_VALID_KEY_MAPPINGS = {
          :username  => :user,
          :realm     => :realm,
          :qop       => :qop,
          :algorithm => :algorithm,
          :uri       => :uri,
          :nonce     => :nonce,
          :nc        => :nc,
          :cnonce    => :cnonce,
          :response  => :response,
        }

        def parse(data, forced_options = {})
          options = HashWithIndifferentAccess.new
          data.to_s.split(/,\s*/).each do |query|
            key, val = query.split('=', 2)
            if valid_key_name = PARAMETER_VALID_KEY_MAPPINGS[key.to_s.intern]
              options[valid_key_name] = val ? val.to_s.delete('"') : nil
#              ActionController::Base.logger.debug("parse: %s => %s" % [valid_key_name,options[valid_key_name]])
            end
          end
          new(options.merge(forced_options))
        end

        def strength
          100
        end
      end

      def set_controller(controller)
        options[:uri]    = controller.request.path
        options[:method] = controller.request.method.to_s.upcase
      end

      def nonce
        value = options[:nonce]
        unless value
          time  = Time.now.to_i
          etag  = options[:session_key] || random(16)
          pkey  = options[:private_key] || random(16)
          value = Base64.encode64("%s:%s:%s" % [time, etag, pkey]).chomp
        end
        return value
      end

      def algorithm
        options[:algorithm] ||= "MD5"
      end

      def qop
        options[:qop] ||= "auth"
      end

      def uri
        options[:uri] ||= '/'
      end

      def nc
        options[:nc] ||= '00000001'
      end

      def cnonce
        options[:cnonce] ||= random(32)
      end

      def method
        options[:method] ||= "GET"
      end

      def response
        options[:response]
      end

      def digest_algorithm
        klass_name = algorithm.to_s.upcase
        if klass_name == "SHA1"
          ::Digest::SHA1
        else
          ::Digest::MD5
        end
      end

      # A1 = unq(username-value) ":" unq(realm-value) ":" passwd
      def a1
        digest_algorithm.hexdigest([user, realm, pass] * ":")
      end

      # A2 = Method ":" digest-uri-value
      def a2
#        debug_digest("a2", %w( method uri))
        digest_algorithm.hexdigest([method, uri] * ":")
      end

      #request-digest  = <"> < KD ( H(A1),     unq(nonce-value)
      #                                ":" nc-value
      #                                ":" unq(cnonce-value)
      #                                ":" unq(qop-value)
      #                                ":" H(A2)
      #                        ) <">
      def request_digest
#        debug_digest("request_digest", %w( a1 nonce nc cnonce qop a2 ))
        digest_algorithm.hexdigest([a1, nonce, nc, cnonce, qop, a2] * ":")
      end

      def response_digest(htdigest)
#        debug_digest("response_digest", %w( htdigest nonce nc cnonce qop a2 ), :htdigest=>htdigest)
        digest_algorithm.hexdigest([htdigest, nonce, nc, cnonce, qop, a2] * ":")
      end

      def server_header
        %Q|Digest realm="%s", nonce="%s", algorithm=%s, qop=%s| % [realm, nonce, algorithm, qop]
      end

      def client_header
        %Q|Digest username="%s", realm="%s", qop=%s, algorithm=%s, uri="%s", nonce="%s", nc=%s, cnonce="%s", response="%s"| %
          [user, realm, qop, algorithm, uri, nonce, nc, cnonce, request_digest]
      end

      ######################################################################
      ### Debug
      def debug_digest(name, element_names, values = {})
        sources = []
        max = element_names.map(&:size).max
        element_names.each do |method|
          value = values[method.intern] || self.send(method)
          logger.debug("[DIGEST] %s#%-*s : %s" % [name, max, method, value])
          sources << value
        end
        digest = digest_algorithm.hexdigest(sources * ':')
        logger.debug("[DIGEST] %s => : %s" % [name, digest])
        return digest
      end        

      ######################################################################
      ### Aliases
      def entry
        [user, realm, a1] * ':'
      end

      ######################################################################
      ### Authorization
      def authorize_pass(pass)
        response_digest(pass) == response or raise IncorrectPassword
      end
    end
    @@schemas["Digest"] = Digest
  end
end
