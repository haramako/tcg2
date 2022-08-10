require "./assert"
require "pp" if RUBY_ENGINE == "ruby"

require "./game"
require "./playing_cards"
require "./poker"

def c(name)
  $game.board.cards.find { |x| x.name == name }
end

def cards(names)
  names.split(" ").map { |name| c(name) }
end

assert("poker matcher") do
  $game = game = PokerRule.new

  matcher = PokerMatcher.new
  assert_equal([:pair, [4, 2]], matcher.match(cards("D1 D2 D3 D4 H4")))
  assert_equal([:two_pairs, [4, 3]], matcher.match(cards("D1 H3 D3 H4 S4")))
  assert_equal([:threecards, [4]], matcher.match(cards("D1 D2 D4 H4 S4")))
  assert_equal([:fourcards, [4]], matcher.match(cards("D1 C4 D4 H4 S4")))
  assert_equal([:fullhouse, [4]], matcher.match(cards("D4 H4 S4 D1 H1")))
  assert_equal([:fullhouse, [4]], matcher.match(cards("D1 H1 D4 H4 S4")))
  assert_equal([:flush, [2]], matcher.match(cards("D1 D2 D3 D4 D6")))
  assert_equal([:straight, [5, 0]], matcher.match(cards("D1 D2 D3 D4 H5")))
  assert_equal([:straight_flush, [2]], matcher.match(cards("D1 D2 D3 D4 D5")))

  # game.board.dump
end

def make_cmd(name, *rest)
  r = Struct.new(name, *rest)
  r.define_method(:type) do name.downcase end
  return r
end

module Cmd
  Start = make_cmd("Start")
  Select = make_cmd("Select", :card)
  Discard = make_cmd("Discard")
  Bet = make_cmd("Bet")
  Reset = make_cmd("Reset")
end

include Cmd

assert("Array#shuffle") do
  ary = (1..10).to_a.shuffle(Random.new(1234))
  assert_equal(55, ary.reduce(0) { |m, i| m + i })
end

assert("poker") do
  game = PokerRule.new
  b = game.board

  game.play Reset[]

  game.play Start[]
  game.play Select[b.hands[0].children[0].id]
  game.play Select[b.hands[0].children[1].id]
  game.play Select[b.hands[0].children[1].id]

  assert_equal(true, game.selectable?(b.hands[0].children[0].id))
  assert_equal(false, game.selectable?(b.hands[1].children[0].id))
  assert_equal(false, game.selectable?(b.stack.children[0].id))

  game.play Discard[]

  assert_equal(1, game.board.cur_player)
  assert_equal(1, game.board.pile.children.size)

  game.play(Select[b.hands[1].children[0].id])
  game.play(Select[b.hands[1].children[1].id])
  game.play Discard[]

  assert_equal(:bet, game.board.state)

  game.play Bet[]
  game.play Reset[]
  game.play Start[]

  #game.board.dump
end

report
