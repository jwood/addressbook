require 'test_helper'

class PlainTextTaggingTest < ActionDispatch::IntegrationTest
  test "does test hasan and yields tagged data" do
    hasan = YAML.load_file('test/fixtures/addresses.yml')['hasan']
    expected = {'name': 'Hasan Diwan', "phone": "+1 4156907930", "address": "2017 North Beverly Glen Blvd., Los Angeles, CA 90077, USA", "email": "hasandiwan@gmail.com", "company": "Jackson Street Capital LLC"}
    post '/addresses', params: {text: hasan}, as: :json # TODO endpoint path
    follow_redirect!
    assert_equal(201, status)
    assert_equal(expected, body)
  end

  test 'Stanford should be tagged as a company' do
    expected = {'company': 'Stanford'}
    post '/addresses', params: {text: 'it may put you in better graces with him for him to know that you have a VC contact out of Stanford, but it is your call'}, as: :json
    follow_redirect!
    assert_equal(201, status)
    assert_equal(expected, body)
  end

end
