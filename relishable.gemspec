Gem::Specification.new do |s|
  s.name = "relishable"
  s.email = "mark.fine@gmail.com"
  s.version = "0.29"
  s.description = "Release manager."
  s.summary = "releases"
  s.authors = ["Mark Fine", "Blake Gentry"]
  s.homepage = "http://github.com/heroku/relish"

  s.files = Dir["lib/**/*.rb"] + Dir["Gemfile*"]
  s.require_paths = ["lib"]
  s.add_dependency "fog"
  s.add_dependency "legacy-fernet"
  s.add_development_dependency "rake",    "> 0"
  s.add_development_dependency "rspec",   "~> 3.1.0"
  s.add_development_dependency "webmock", "~> 1.19.0"
end
