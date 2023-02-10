require "rake/testtask"

task default: "test"

puts "#{__FILE__} #{__LINE__}"
Rake::TestTask.new do |task|
  task.libs << "test/support"
  task.pattern = "test/**/*_test.rb"
end