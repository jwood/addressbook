require File.dirname(__FILE__) + '/test_helper'

class TestController <  ActionController::Base
  def self.external_password_path(file)
    File.dirname(__FILE__) + '/fixtures/' + file
  end

  def index
    render :nothing=>true
  end
end

class HtdigestTestCase < Test::Unit::TestCase
  class Controller <  TestController; end

  def setup
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    @controller = self.class::Controller.new
  end

  def digest_authorization(username, password, method = :get)
    send(method, :index)
    digest = Htpasswd::Auths::Digest.parse(@response.headers['WWW-Authenticate'])
    digest.set_controller(@controller)
    digest.options[:user] = username
    digest.options[:pass] = password

    setup
    @request.env["HTTP_AUTHORIZATION"] = digest.client_header
  end

  def test_dummy
  end
end


class InlineEntryTest < HtdigestTestCase
  class Controller <  TestController
    htdigest :user=>"maiha", :pass=>"berryz", :realm=>"Authorization"
  end

  def test_content_should_be_authorized
    get :index
    assert_response 401
    assert /\ADigest / === @response.headers["WWW-Authenticate"].to_s
  end

  def test_authorize_valid_request
    digest_authorization('maiha', 'berryz')
    get :index
    assert_response :success
  end

  def test_authorize_valid_request
    digest_authorization('maiha', 'berryz')
    get :index
    assert_response :success
  end
end


class InlineMultiEntriesTest < HtdigestTestCase
  class Controller <  TestController
    htdigest :user=>"maiha", :pass=>"berryz"
    htdigest :user=>"airi",  :pass=>"cute"
  end

  def test_content_should_be_authorized
    get :index
    assert_response 401
  end

  def test_authorize_valid_request_written_in_first_entry
    digest_authorization('maiha', 'berryz')
    get :index
    assert_response :success
  end

  def test_authorize_valid_request_written_in_second_entry
    digest_authorization('airi', 'cute')
    get :index
    assert_response :success
  end

  def test_authorize_invalid_request
    digest_authorization('maiha', 'xxx')
    get :index
    assert_response 401
  end
end


class InlineCryptedEntryTest < HtdigestTestCase
  class Controller <  TestController
    htdigest :user=>"maiha", :pass=>"812b1d067e9ce1e44f09215339e3cd69", :realm=>"Authorization", :type=>:crypted
  end

  def test_authorize_valid_request
    digest_authorization('maiha', 'berryz')
    get :index
    assert_response :success
  end

  def test_authorize_invalid_request
    digest_authorization('maiha', 'xxx')
    get :index
    assert_response 401
  end
end


class ExternalFileTest < HtdigestTestCase
  class Controller <  TestController
    htdigest :file=>external_password_path('htdigest.berryz')
  end

  def test_content_should_be_authorized
    get :index
    assert_response 401
  end

  def test_authorize_valid_request_written_in_first_entry
    digest_authorization('maiha', 'berryz')
    get :index
    assert_response :success
  end

  def test_authorize_valid_request_written_in_second_entry
    digest_authorization('saki', 'berryz')
    get :index
    assert_response :success
  end

  def test_authorize_invalid_request
    digest_authorization('airi', 'cute')
    get :index
    assert_response 401
  end
end


class CompositeTest < HtdigestTestCase
  class Controller <  TestController
    htdigest :user=>"risako" , :pass=>"berryz"
    htdigest :user=>"yurina" , :pass=>"f278b3900164e31fcf005a79a8b2da2e", :type=>:crypted
    htdigest :file=>external_password_path('htdigest.berryz')
    htdigest :file=>external_password_path('htdigest.cute')
  end

  def test_content_should_be_authorized
    get :index
    assert_response 401
  end

  def test_authorize_inline_entry
    digest_authorization('risako', 'berryz')
    get :index
    assert_response :success
  end

  def test_authorize_inline_crypted_entry
    digest_authorization('yurina', 'berryz')
    get :index
    assert_response :success
  end

  def test_authorize_external_first_file
    # first entry
    digest_authorization('maiha', 'berryz')
    get :index
    assert_response :success

    # second entry
    setup
    digest_authorization('saki', 'berryz')
    get :index
    assert_response :success
  end

  def test_authorize_external_second_file
    # first entry
    digest_authorization('airi', 'cute')
    get :index
    assert_response :success

    # second entry
    setup
    digest_authorization('maimi', 'cute')
    get :index
    assert_response :success
  end

  def test_authorize_invalid_request
    digest_authorization('maiha', 'cute')
    get :index
    assert_response 401
  end
end

class InlineEntryTest < HtdigestTestCase
  class Controller <  TestController
    htdigest :user=>"maiha" , :pass=>"berryz"
  end

  def test_authorize_with_post
    digest_authorization('maiha', 'berryz', :post)
    post :index
    assert_response :success
  end
end
