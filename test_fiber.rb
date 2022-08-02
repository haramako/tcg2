f = Fiber.new do
  puts 1
  Fiber.yield(1)
  puts 2
  Fiber.yield(2)
end

puts f.resume
puts f.resume
puts f.alive?
p f.resume
puts f.alive?
