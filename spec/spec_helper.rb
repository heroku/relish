require "rubygems"
require "bundler"

require "date" # work around issue with safe_yaml
Bundler.require(:default, :development)

require "webmock/rspec"

require "relish"

RSpec.configure do |config|
  config.expect_with :test_unit
end
