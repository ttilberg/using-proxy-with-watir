# frozen_string_literal: true

require 'watir'
require 'uri'

# The main tests to jump through for each browser configuration
#
module InterestingTests
  # i_dont_suck_and_my_tests_are_not_order_dependent!_but_i_want_them_to_be
  def self.test_order
    :sorted
  end

  def teardown
    @browser.close if @browser.respond_to? :close
  end

  ##
  # The main test factory
  # Configures a browser with the given options and runs the assertions.
  #
  def run_test_with(test_opts = {})
    opts = default_options.merge test_opts
    @browser = Watir::Browser.new browser_type, opts
    assert_http_proxy
    assert_https_proxy
  end

  ##
  # The simple test case: Can I pass a params hash to build the proxy object?
  # I find this very developer friendly
  #
  def test_using_proxy_params_hash
    proxy = {
      http: PROXY,
      ssl:  PROXY
    }

    run_test_with proxy: proxy
  end

  ##
  # Some proxy tools require "http://" to be preceeded and some do not.
  # Which is this?
  #
  # This small detail throws the Firefox drivers for a loop! Selenium
  # complains that we specified the `http://` scheme.
  #
  # Surprising! Watch out!
  #
  def test_using_params_hash_with_http_scheme
    proxy = {
      http: "http://#{PROXY}",
      ssl:  "http://#{PROXY}"
    }

    run_test_with proxy: proxy
  end

  ##
  # We should be able to also put a Selenium::WebDriver::Proxy
  # object in there.
  #
  def test_using_proxy_object
    proxy = Selenium::WebDriver::Proxy.new(
      http: PROXY,
      ssl:  PROXY
    )

    run_test_with proxy: proxy
  end

  ##
  # Can we build a Proxy object from a URI with HTTP scheme?
  #
  # This might be a helpful technique if your proxy representation includes
  # the scheme, since it would be more widely supported.
  #
  def test_using_proxy_object_from_uri_with_http_scheme
    proxy = Selenium::WebDriver::Proxy.new(
      http: URI("http://#{PROXY}"),
      ssl:  URI("http://#{PROXY}")
    )

    run_test_with proxy: proxy
  end

  ##
  # Can we build a Proxy object from a URI that doesn't have scheme?
  #
  # This might be a helpful technique if your proxy representation includes
  # the scheme, since it would be more widely supported.
  #
  def test_using_proxy_object_from_uri_without_http_scheme
    proxy = Selenium::WebDriver::Proxy.new(
      http: URI("http://#{PROXY}"),
      ssl:  URI("http://#{PROXY}")
    )

    run_test_with proxy: proxy
  end

  ##
  # This is a common documented feature for doing a proxy with Chrome.
  #
  # Interestingly, it works when using Chrome natively, but not remotely.
  #
  def test_using_switches_argument
    run_test_with switches: ["--proxy-server=#{PROXY}"]
  end

  ##
  # This is a common documented feature for doing a proxy with Chrome.
  #
  # Interestingly, it works when using Chrome natively, but not remotely.
  #
  def test_using_switches_argument_with_http_scheme
    run_test_with switches: ["--proxy-server=http://#{PROXY}"]
  end

  private

  def assert_http_proxy
    @browser.goto 'http://api.ipify.org'
    assert(
      @browser.text.include?(PROXY_HOST),
      'Proxy did not change for HTTP connection'
    )
  end

  def assert_https_proxy
    @browser.goto 'https://api.ipify.org'
    assert(
      @browser.text.include?(PROXY_HOST),
      'Proxy did not change for HTTPS connection. Did you set ssl proxy?'
    )
  end

  def default_options
    {}
  end
end
