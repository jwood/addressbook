module Htpasswd
  module Acls
    class Htdigest < CompositeBase
      def initialize_composite(options)
        IO.foreach(options[:file]) do |line|
          user, realm, pass = line.chomp.split(':', 3)
          self << Acls::Digest.new(:user=>user, :realm=>realm, :pass=>pass)
        end
      rescue => err
        logger.debug("%s: [%s]%s" % [self.class, err.class, err])
        raise ConfigurationError, "Cannot read password file. '#{options[:file]}'"
      end

      register self
    end
  end
end
