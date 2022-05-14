def c(name)
  $game.cards.find { |x| x.name == name }
end

def cards(names)
  names.split(" ").map { |name| c(name) }
end

assert("poker matcher") do
  $game = game = Poker.new

  matcher = PokerMatcher.new
  assert_equal([:pair, [4, 2]], matcher.match(cards("D1 D2 D3 D4 H4")))
  assert_equal([:two_pairs, [4, 3]], matcher.match(cards("D1 H3 D3 H4 S4")))
  assert_equal([:threecards, [4]], matcher.match(cards("D1 D2 D4 H4 S4")))
  assert_equal([:fourcards, [4]], matcher.match(cards("D1 C4 D4 H4 S4")))
  assert_equal([:flush, [2]], matcher.match(cards("D1 D2 D3 D4 D6")))
  assert_equal([:straight, [5, 0]], matcher.match(cards("D1 D2 D3 D4 H5")))
  assert_equal([:straight_flush, [2]], matcher.match(cards("D1 D2 D3 D4 D5")))

  # game.board.dump
end

assert("poker") do
  $game = game = Poker.new
end
