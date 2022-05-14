include Game

def create_board(place_count, card_count)
  b = Board.new
  places = (0...place_count).map { |i| CardPlace.new(b, "place#{i}") }
  cards = (0...card_count).map { |i| Card.new(b, "card#{i}") }
  [b, places, cards]
end

assert("board") do
  b, h, c = create_board(2, 1)

  c[0].move(h[0])
  assert_equal(1, h[0].children.size)
  assert_equal(0, h[1].children.size)
  assert_equal(c[0], h[0].children[0])

  c[0].move(h[1])
  assert_equal(0, h[0].children.size)
  assert_equal(1, h[1].children.size)
  assert_equal(c[0], h[1].children[0])

  #b.dump
  #p b.render
end

assert("porker") do
  $game = game = Poker.new

  def cards(names)
    names.split(" ").map do |name|
      $game.cards.find { |x| x.name == name }
    end
  end

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
