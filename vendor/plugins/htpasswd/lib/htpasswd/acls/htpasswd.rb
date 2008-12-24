module Htpasswd
  module Acls
    class Htpasswd < CompositeBase
      def initialize_composite(options)
        IO.foreach(options[:file]) do |line|
          user, pass = line.chomp.split(':', 2)
          self << Crypted.new(:type=>:crypted, :user=>user, :pass=>pass)
        end
      rescue => err
        logger.debug("%s: [%s]%s" % [self.class, err.class, err])
        raise ConfigurationError, "Cannot read password file. '#{options[:file]}'"
      end

      register self
    end
  end
end
