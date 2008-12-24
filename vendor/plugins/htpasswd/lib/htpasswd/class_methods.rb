module Htpasswd
  def self.included(base)
    base.extend(ClassMethods)
  end

  class Error              < StandardError; end
  class HeaderNotFound     < Error; end
  class UnknownSchemeError < Error; end
  class NotAuthorizedError < Error; end
  class ConfigurationError < Error; end

  class UnknownAccessControl  < ConfigurationError; end
  class AuthSchemesNotDefined < ConfigurationError; end
  class IncorrectPassword     < NotAuthorizedError; end
  class UnknownUserAccount    < NotAuthorizedError; end

  module ClassMethods
    def htpasswd(options={})
      options = options.dup
      options[:user] ||= options[:username]
      options[:pass] ||= options[:password]
      options[:acl]  ||= options[:type]

      if options[:exclusive]
        write_inheritable_array(:htpasswd_acls, [])
        write_inheritable_hash(:htpasswd_options, {})
      end

      (htpasswd_options[:schemes] ||= Set.new) << (options[:scheme] || :basic)

      options[:acl] ||= (options[:class] && :active_record)
      options[:acl] ||= (options[:file]  && :htpasswd)
      options[:acl] ||= (options[:user]  && options[:pass] && :plain)

      htpasswd_acls << Acls::Base[options[:acl]].new(options) if options[:acl]
      htpasswd_options.merge!(:realm=>options[:realm])        if options[:realm]

      skip_before_filter :htpasswd_authorize rescue nil
      delegate :htpasswd_options, :htpasswd_acls, :to=>"self.class" unless instance_methods.include?("htpasswd_options")
      before_filter :htpasswd_authorize
    end

    def htdigest(options={})
      options = options.dup
      if options[:user] && options[:pass] && (options[:acl] || options[:type]) != :crypted && options[:class].blank?
        options[:pass] = Auths::Digest.new(options).a1
      end
      options[:scheme] = :digest
      options[:acl] ||= (options[:class] && :active_record)
      options[:acl] ||= (options[:file] ? :htdigest : :digest)

      htpasswd(options)
    end

    def htpasswd_options
      read_inheritable_attribute(:htpasswd_options) or write_inheritable_hash(:htpasswd_options, {})
    end

    def htpasswd_acls
      read_inheritable_attribute(:htpasswd_acls) or write_inheritable_array(:htpasswd_acls, [])
    end
  end

  protected
  def htpasswd_authorize
    logger.debug "Htpasswd is enabled with %s" % htpasswd_options.inspect
    username = Auths.scheme(self).authorize(htpasswd_acls)
    logger.debug "Htpasswd authorize user '%s'" % username
    @htpasswd_authorized_username = username
    return true
  rescue Htpasswd::Error => error
    logger.debug "Htpasswd error(%s): %s" % [error.class, error.message]
    strongest_auth = htpasswd_options[:schemes].map{|scheme| Auths[scheme]}.sort.last or raise AuthSchemesNotDefined
    response.headers['WWW-Authenticate'] = strongest_auth.new(htpasswd_options).server_header
    logger.debug "Htpasswd sending authenticate header: '%s'"% response.headers['WWW-Authenticate']

    render :nothing => true, :status => 401
    return false
  end
end
