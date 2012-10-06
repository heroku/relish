Gem::Specification.new do |s|
  s.name = "relishable"
  s.email = "mark.fine@gmail.com"
  s.version = "0.2"
  s.description = "Release manager."
  s.summary = "releases"
  s.authors = ["Mark Fine"]
  s.homepage = "http://github.com/heroku/relish"

  s.files = Dir["lib/**/*.rb"] + Dir["Gemfile*"]
  s.require_paths = ["lib"]
  s.add_dependency "press"
  s.add_dependency "fog"
end
