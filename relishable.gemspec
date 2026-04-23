$:.unshift File.expand_path("../lib", __FILE__)
require "relish/version"

Gem::Specification.new do |s|
  s.name = "relishable"
  s.email = ["mark.fine@gmail.com", "opensource@heroku.com"]
  s.version = Relish::VERSION
  s.description = "Release manager."
  s.summary = "releases"
  s.authors = ["Mark Fine", "Blake Gentry", "Pedro Belo", "Joshua Tobin"]
  s.homepage = "http://github.com/heroku/relish"
  s.required_ruby_version = ">= 3.1.0"

  s.files = Dir["lib/**/*.rb"] + Dir["Gemfile*"]
  s.require_paths = ["lib"]
  s.add_dependency "fog-aws", ">= 3.18", "< 3.34"
  s.add_dependency "fernet", "~> 2.3"
  s.add_dependency "net-ssh", ">= 7.1", "< 7.4"
  s.add_dependency "nokogiri"
  s.add_dependency "bigdecimal"
  s.add_dependency "base64"
  s.add_development_dependency "rake"
  s.add_development_dependency "rspec"
  s.add_development_dependency "test-unit"
  s.add_development_dependency "webmock"
  s.add_development_dependency "pry"
  s.add_development_dependency "simplecov"
end
