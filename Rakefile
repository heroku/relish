$:.unshift File.expand_path("../lib", __FILE__)
require 'rspec/core/rake_task'
require 'relish/version'

RSpec::Core::RakeTask.new(:spec)


task default: :spec
desc "Cut a new version specified in VERSION and push"
task :release do
  unless ENV['VERSION']
    abort("ERROR: Missing VERSION. Currently at #{Relish::VERSION}. Ex: rake release VERSION=1.0.0")
  end

  current_version = Gem::Version.new(Relish::VERSION)
  new_version = Gem::Version.new(ENV["VERSION"])

  # if current_version >= new_version
  #   abort("ERROR: Invalid version, already at #{Relish::VERSION}")
  # end

  sh "ruby", "-i", "-pe", "$_.gsub!(/VERSION = .*/, %{VERSION = \"#{new_version}\"})", "lib/relish/version.rb"
  sh "bundle install"
  sh "git commit -a -m 'v#{new_version}'"
  sh "git tag v#{new_version} && git push origin master --tags"
  sh "gem build relishable.gemspec"
  sh "gem push relishable-#{new_version}.gem"
  sh "git push origin master --tags"
  sh "rm relishable-#{new_version}.gem"
end

