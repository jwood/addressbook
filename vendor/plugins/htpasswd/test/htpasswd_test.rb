require File.dirname(__FILE__) + '/test_helper'

class TestController <  ActionController::Base
  def self.external_password_path(file)
    File.dirname(__FILE__) + '/fixtures/' + file
  end

  def index
    render :nothing=>true
  end
end

class HtpasswdTestCase < Test::Unit::TestCase
  class Controller <  TestController; end

  def setup
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    @controller = self.class::Controller.new
  end

  def basic_authorization(user, pass)
    @request.env["HTTP_AUTHORIZATION"] = "Basic %s" % Base64.encode64("#{user}:#{pass}")
  end

  def test_dummy
  end
end


class InlineEntryTest < HtpasswdTestCase
  class Controller <  TestController
    htpasswd :user=>"maiha", :pass=>"berryz"
  end

  def test_content_should_be_authorized
    get :index
    assert_response 401
    assert_equal 'Basic realm="Authorization"', @response.headers["WWW-Authenticate"].to_s
  end

  def test_authorize_valid_request
    basic_authorization('maiha', 'berryz')
    get :index
    assert_response :success
  end

  def test_authorize_invalid_request
    basic_authorization('maiha', 'xxx')
    get :index
    assert_response 401
  end
end


class InlineMultiEntriesTest < HtpasswdTestCase
  class Controller <  TestController
    htpasswd :user=>"maiha", :pass=>"berryz"
    htpasswd :user=>"airi",  :pass=>"cute"
  end

  def test_content_should_be_authorized
    get :index
    assert_response 401
  end

  def test_authorize_valid_request_written_in_first_entry
    basic_authorization('maiha', 'berryz')
    get :index
    assert_response :success
  end

  def test_authorize_valid_request_written_in_second_entry
    basic_authorization('airi', 'cute')
    get :index
    assert_response :success
  end

  def test_authorize_invalid_request
    basic_authorization('maiha', 'xxx')
    get :index
    assert_response 401
  end
end


class InlineCryptedEntryTest < HtpasswdTestCase
  class Controller <  TestController
    htpasswd :user=>"maiha", :pass=>"7Et1Y7tCawx32", :type=>:crypted
  end

  def test_content_should_be_authorized
    get :index
    assert_response 401
  end

  def test_authorize_valid_request
    basic_authorization('maiha', 'berryz')
    get :index
    assert_response :success
  end

  def test_authorize_invalid_request
    basic_authorization('maiha', 'xxx')
    get :index
    assert_response 401
  end
end


class ExternalFileTest < HtpasswdTestCase
  class Controller <  TestController
    htpasswd :file=>external_password_path('htpasswd.berryz')
  end

  def test_content_should_be_authorized
    get :index
    assert_response 401
  end

  def test_authorize_valid_request_written_in_first_entry
    basic_authorization('maiha', 'berryz')
    get :index
    assert_response :success
  end

  def test_authorize_valid_request_written_in_second_entry
    basic_authorization('saki', 'berryz')
    get :index
    assert_response :success
  end

  def test_authorize_invalid_request
    basic_authorization('airi', 'cute')
    get :index
    assert_response 401
  end
end


class CompositeTest < HtpasswdTestCase
  class Controller <  TestController
    htpasswd :user=>"risako" , :pass=>"berryz"
    htpasswd :user=>"yurina" , :pass=>"7Et1Y7tCawx32", :type=>:crypted
    htpasswd :file=>external_password_path('htpasswd.berryz')
    htpasswd :file=>external_password_path('htpasswd.cute')
  end

  def test_content_should_be_authorized
    get :index
    assert_response 401
  end

  def test_authorize_inline_entry
    basic_authorization('risako', 'berryz')
    get :index
    assert_response :success
  end

  def test_authorize_inline_crypted_entry
    basic_authorization('yurina', 'berryz')
    get :index
    assert_response :success
  end

  def test_authorize_external_first_file
    # first entry
    basic_authorization('maiha', 'berryz')
    get :index
    assert_response :success

    # second entry
    setup
    basic_authorization('saki', 'berryz')
    get :index
    assert_response :success
  end

  def test_authorize_external_second_file
    # first entry
    basic_authorization('airi', 'cute')
    get :index
    assert_response :success

    # second entry
    setup
    basic_authorization('maimi', 'cute')
    get :index
    assert_response :success
  end

  def test_authorize_invalid_request
    basic_authorization('maiha', 'cute')
    get :index
    assert_response 401
  end
end


class RealmTest < HtpasswdTestCase
  class Controller <  TestController
    htpasswd :user=>"maiha", :pass=>"berryz", :realm=>"Member Only"
  end

  def test_set_realm
    get :index
    assert_equal 'Basic realm="Member Only"', @response.headers["WWW-Authenticate"].to_s
  end
end

