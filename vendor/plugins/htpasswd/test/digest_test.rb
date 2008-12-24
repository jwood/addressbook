require File.dirname(__FILE__) + '/test_helper'

class DigestTestCase < Test::Unit::TestCase
  def test_calculate_request_digest
    options = {
      :username  => "maiha",
      :password  => "berryz",
      :realm     => "Authorization",
      :nonce     => "MTE0ODYxODUxNDozNGJhZDVhMzQ2YjBiM2QzOmQwMTVhYjdlNGJkZjkzMjk=",
      :uri       => "/test",
      :algorithm => "MD5",
      :cnonce    => "cnonce",
      :qop       => "auth",
      :nc        => "00000001",
    }
    expected = "4d7849b4faab53fd3eff731c24cc24d1"
    digest   = Htpasswd::Authorization::Digest.new(options)
    assert_equal expected, digest.request_digest
  end

  def test_calculate_response_digest
    options = {
      :username  => "maiha",
      :password  => "berryz",
      :realm     => "Authorization",
      :nonce     => "MTE0ODYxODUxNDozNGJhZDVhMzQ2YjBiM2QzOmQwMTVhYjdlNGJkZjkzMjk=",
      :uri       => "/test",
      :algorithm => "MD5",
      :cnonce    => "cnonce",
      :qop       => "auth",
      :nc        => "00000001",
    }
    expected = "4d7849b4faab53fd3eff731c24cc24d1"
    htdigest = "812b1d067e9ce1e44f09215339e3cd69"
    digest   = Htpasswd::Authorization::Digest.new(options)
    assert_equal expected, digest.response_digest(htdigest)
  end
end
