require 'htpasswd/class_methods'

require 'htpasswd/acls/base'
require 'htpasswd/acls/plain'
require 'htpasswd/acls/crypted'
require 'htpasswd/acls/digest'
require 'htpasswd/acls/htpasswd'
require 'htpasswd/acls/htdigest'
require 'htpasswd/acls/active_record'

require 'htpasswd/auths/base'
require 'htpasswd/auths/basic'
require 'htpasswd/auths/digest'

ActionController::Base.send(:include, Htpasswd)
