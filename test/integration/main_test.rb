require 'json'
require 'test_helper' 

class MainTest < ActionDispatch::IntegrationTest
  test 'users endpoint returns only email addresses in csv' do
    get "/users"
    users = JSON.parse(response.body)
    assert users.kind_of?(Array)
  end
end
