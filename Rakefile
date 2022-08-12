task :test do
  sh "mruby", "-r", "Ruby/prelude.rb", "Ruby/test_dummy.rb"
  sh "mruby", "-r", "Ruby/prelude.rb", "Ruby/test_poker.rb"
end

task :fiber do
  sh "mruby", "-r", "Ruby/prelude.rb", "Ruby/test_fiber.rb"
end
