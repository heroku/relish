require "rake/testtask"

task :default => :test

Rake::TestTask.new do |task|
  task.libs << "lib"
  task.libs << "test"
  task.name = :test
  task.test_files = FileList['test/**/*_test.rb']
end
