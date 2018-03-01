# frozen_string_literal: true

require_relative 'interesting_tests'

# Each browser configuration includes the test module.
# This gets `minitest/autorun` to jump through the hoops for each config.
#
# These classes should implement a `browser_type` method, and
# `default_options` if required. These are used to construct your browser:
#
#    Watir::Browser.new browser_type, default_options.merge(test_options)
#
class ChromeTest < Minitest::Test
  include InterestingTests

  def browser_type
    :chrome
  end

  def default_options
    {}
  end
end

class FirefoxTest < Minitest::Test
  include InterestingTests

  def browser_type
    :firefox
  end

  def default_options
    {}
  end
end

class RemoteChromeTest < ChromeTest
  def default_options
    { url: CHROME_SELENIUM }
  end
end

class RemoteFirefoxTest < FirefoxTest
  def default_options
    { url: FIREFOX_SELENIUM }
  end
end
