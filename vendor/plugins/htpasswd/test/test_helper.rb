def __DIR__; File.dirname(__FILE__); end

require 'test/unit'
$:.unshift(__DIR__ + '/../lib')
begin
  require 'rubygems'
rescue LoadError
  $:.unshift(__DIR__ + '/../../../rails/activesupport/lib')
  $:.unshift(__DIR__ + '/../../../rails/actionpack/lib')
end

require 'active_support'
require 'action_controller'
require 'action_controller/test_process'

ActionController::Routing::Routes.reload rescue nil
class ActionController::Base; def rescue_action(e) raise e end; end

logfile      = __DIR__ + '/debug.log'
File.unlink(logfile) if File.exists?(logfile)
logger       = Logger.new(logfile)
logger.level = Logger::DEBUG
ActionController::Base.logger = logger

require __DIR__ + '/../init'
