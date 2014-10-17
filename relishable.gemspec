$:.unshift File.expand_path("../lib", __FILE__)
require "relish/version"

Gem::Specification.new do |s|
  s.name = "relishable"
  s.email = "mark.fine@gmail.com"
  s.version = Relish::VERSION
  s.description = "Release manager."
  s.summary = "releases"
  s.authors = ["Mark Fine", "Blake Gentry"]
  s.homepage = "http://github.com/heroku/relish"

  s.files = Dir["lib/**/*.rb"] + Dir["Gemfile*"]
  s.require_paths = ["lib"]
  s.add_dependency "fog",           "~> 1.23.0"
  s.add_dependency "legacy-fernet", "~> 1.6.3"
  s.add_development_dependency "rake",    "> 0"
  s.add_development_dependency "rspec",   "~> 3.1.0"
  s.add_development_dependency "webmock", "~> 1.19.0"
end
