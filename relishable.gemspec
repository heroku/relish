$:.unshift File.expand_path("../lib", __FILE__)
require "relish/version"

Gem::Specification.new do |s|
  s.name = "relishable"
  s.email = ["pedro@heroku.com", "mark.fine@gmail.com", "tobin@heroku.com", "opensource@heroku.com"]
  s.version = Relish::VERSION
  s.description = "Release manager."
  s.summary = "releases"
  s.authors = ["Mark Fine", "Blake Gentry", "Pedro Belo", "Joshua Tobin"]
  s.homepage = "http://github.com/heroku/relish"

  s.files = Dir["lib/**/*.rb"] + Dir["Gemfile*"]
  s.require_paths = ["lib"]
  s.add_dependency "fog-aws",       "~> 0.8.0"
  s.add_dependency "fernet",        "~> 2.3"
  s.add_dependency "net-ssh",       "~> 6.1.0"
  s.add_development_dependency "rake",    "> 0"
  s.add_development_dependency "rspec",   "~> 3.10.0"
  s.add_development_dependency "test-unit"
  s.add_development_dependency "webmock", "~> 3.14.0"
  s.add_development_dependency "pry-byebug"
end
