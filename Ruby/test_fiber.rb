f = Fiber.new do |x1|
  p [:fiber, x1]
  x = Fiber.yield(1)
  x = Fiber.resume(1)
  p [:fiber, x]
  Fiber.yield(x + 1)
end

begin
  puts "start"
  puts f.resume(1)
  puts f.resume(1)
  puts f.alive?
  p f.resume
  puts f.alive?
rescue => ex
  p ex
  f.resume(1)
end
