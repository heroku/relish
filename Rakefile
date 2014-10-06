task default: :test

task :test do
  require "rspec"
  code = RSpec::Core::Runner.run(
    ["spec/"], $stderr, $stdout)
  exit(code) unless code == 0
end
