# Testing compatibility for using Proxies with Watir

I spent a lot of time trying to understand how I could successfully route a connection with Watir/Selenium through a proxy. In the process, I came across a lot of information that was conflicting, or simply didn't work. This led me down a path to figure out what *does* work, and what sort of "gotchas" still exist.

This project has a test file that can be run that will exercise a bunch of different ways to try and create proxies against multiple browser configurations.

There is a main module that contains the tests, and then classes that implement the tests with various `Watir::Browser.new` configuration options.

# Results:

Based on the experience above, I'm certain this is not accurate across all versions, but as of February 2018, using the current versions of Watir, Selenium, Chrome and Firefox, I've found that the ideal way to specify a proxy is to either pass a `Selenium::WebDriver::Proxy`, or the parameters to create one into the `:proxy` key of the options hash using strictly the host/IP and port.

```ruby
require 'watir'

proxy_object = Selenium::WebDriver::Proxy.new(
  http: '127.0.0.1:8080',
  ssl:  '127.0.0.1:8080'
)

browser = Watir::Browser.new :chrome, proxy: proxy_object
```

Under the hood, this eventually creates a `Selenium::WebDriver::Remote::Capabilites` object and sets the `proxy` attribute. The `Capabilities#proxy=` method is [able to discern](https://github.com/SeleniumHQ/selenium/blob/b576ae507c909ee287efc2af25916c8f17539893/rb/lib/selenium/webdriver/remote/capabilities.rb#L209) whether it was passed an existing `Proxy` object, or just the hash needed to create one:

```ruby
require 'watir'

proxy_hash = {
  http: '127.0.0.1:8080',
  ssl:  '127.0.0.1:8080'
}
browser = Watir::Browser.new :chrome, proxy: proxy_hash
```

This method is compatible with `:chrome`, `:firefox`, and remote versions using `url: URL` when setting up a `Watir::Browser`.

Unfortunately, I don't know how to get a proxy working with Edge. None of the example test variations have worked.

# Some interesting things regarding my `interesting_tests`:

#### Leave `http://` at home:

Unfortunately many tools have different expectations of whether your proxy string should include `http://` or not. I was surprised to learn that the answer in this case is "it depends." Both native Chrome/ChromeDriver and Remote Chrome via the [selenium/standalone-chrome container](https://github.com/SeleniumHQ/docker-selenium) were happy to accept either form of `127.0.0.1:8080` or `http://127.0.0.1:8080` when specifying a proxy. However, similar configurations for Firefox raise exception from including the `http://` scheme. This appears to be at the driver level, because **this still holds true if you first instantiate a `Selenium::WebDriver::Proxy` object with these options!**.

#### Casting to URI doesn't help:

I thought perhaps if I used a URI instead of a string, there would be a better chance for the Firefox tests to pass when using a proxy string with scheme. Nope. No dice.

#### Don't both with `switches: [--proxy-server]`

There are many examples and documentation for using a proxy with Chrome via the `--proxy-server=` command line argument. If you pass this in when executing chrome, it overrides the system proxy. Avoid this method if you can: It doesn't seem to work when running remotely -- only natively. And it's specific to Chrome. And the generic, abstracted way works these days --- so why wouldn't you just use that?

# Run the tests yourself

### What you'll need:
  - [Ruby](https://www.ruby-lang.org/en/) (!)
  - [Docker-Compose to automate some remote Selenium browsers](https://docs.docker.com/compose/)
  - [Chrome](https://www.google.com/chrome/)
  - [ChromeDriver to automate Chrome](https://sites.google.com/a/chromium.org/chromedriver/)
  - [Firefox](https://www.mozilla.org/en-US/firefox/new/)
  - [geckodriver to automate Firefox](https://developer.mozilla.org/en-US/docs/Mozilla/QA/Marionette/WebDriver)
  - [Edge](https://www.microsoft.com/en-us/windows/microsoft-edge)
  - [MicrosoftWebDriver to automate Edge](https://developer.microsoft.com/en-us/microsoft-edge/tools/webdriver/)
  - Any other browsers, and automation drivers that you wish to add!

### Fire ze missiles

In order to set the tests up, you'll need to get the remote browsers cooking:

```
λ docker-compose up -d
```

> **_NOTE:_** _Don't forget to `docker-compose down` later!_

> **_MORE NOTE:_** _You can leave the `-d` flag off if you want to watch the matrix. This will help you remember to get `down`._

and set the following environment variables while you fire off the command.

Bash: 
```
λ PROXY_HOST=127.0.0.1 PROXY_PORT:8080 ruby test.rb
```

Windows (Sorry, I don't know how to inline these `:(`):
```
λ set PROXY_HOST=127.0.0.1
λ set PROXY_PORT=8080
λ ruby test.rb
```


### ???

The test runs against the following browser configurations:
  - local, native Chrome
  - local, native Firefox
  - remote Chrome
  - remote Firefox

To add more, just create more test classes using the existing ones as templates.

The proxy should have an IP that is different from your local connection. This is how we can verify that the proxy is in fact registering correctly.

The script will use these values to exercise the options, and assert the results against http://api.ipify.org and https://api.ipify.org. I think it's important to test against both, since you must set both options separately in your proxy config. We're trying to find the edge cases here!
