Gem::Specification.new do |s|
  s.name = "relishable"
  s.email = "mark.fine@gmail.com"
  s.version = "0.11"
  s.description = "Release manager."
  s.summary = "releases"
  s.authors = ["Mark Fine", "Blake Gentry"]
  s.homepage = "http://github.com/heroku/relish"

  s.files = Dir["lib/**/*.rb"] + Dir["Gemfile*"]
  s.require_paths = ["lib"]
  s.add_dependency "fog", "~> 1.6"
  s.add_dependency "fernet", "~> 1.4"
end
