require "rubygems"
require "bundler"

Bundler.require(:default, :development)

require "minitest/spec"
require "minitest/autorun"
require "webmock/minitest"

require "relish"