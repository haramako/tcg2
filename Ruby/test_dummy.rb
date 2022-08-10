$LOAD_PATH << "Ruby"

require "assert"
require "pp" if RUBY_ENGINE == "ruby"

require "dummy"
include Dummy::Cmd

assert("dummy play") do
  game = Dummy::DummyRule.new
  b = game.board

  assert_equal(:start, game.state)

  game.play Start[]

  assert_equal(:playing, game.state)

  game.play Move[b.hands[0], b.fields[0]]

  # b.dump

  game.play Reset[]
end

report
