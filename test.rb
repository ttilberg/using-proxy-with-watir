# frozen_string_literal: true

require 'minitest/autorun'

#=======================================
# Environment Configuration:
#---------------------------------------

# Set the env vars `PROXY_HOST` and `PROXY_PORT` to a working external proxy.
PROXY_HOST = ENV.fetch 'PROXY_HOST'
PROXY_PORT = ENV.fetch 'PROXY_PORT'

PROXY = "#{PROXY_HOST}:#{PROXY_PORT}"

# Fire up docker-compose to get these guys cookin':
#
# In it's own terminal:
#    $ docker-compose up
# or as a background daemon (dont' forget to `docker-compose down`!)
#    $ docker-compose up -d
#
CHROME_SELENIUM  = 'http://localhost:4444/wd/hub'
FIREFOX_SELENIUM = 'http://localhost:5555/wd/hub'

#=======================================

# Run the `intereseting_tests` for each browser_configuration:
require_relative 'test/browser_configurations'