Warning[:deprecated] = true

require "simplecov"
SimpleCov.start do
  # Keeps simplecov from calculating coverage of the spec files themselves
  add_filter "spec"
end

require "rubygems"
require "bundler"

require "date" # work around issue with safe_yaml
Bundler.require(:default, :development)

require "webmock/rspec"

require "relish"

RSpec.configure do |config|
  config.expect_with :test_unit
end
