require "rubygems"
require "bundler"

Bundler.require(:default, :development)

require "webmock/rspec"

require "relish"

RSpec.configure do |config|
  config.expect_with :test_unit
end
