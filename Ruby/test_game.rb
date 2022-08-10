def create_board(place_count, card_count)
  b = Game::Board.new
  places = (0...place_count).map { |i| Game::PlaceHolder.new(b, "place#{i}") }
  cards = (0...card_count).map { |i| Game::Card.new(b, "card#{i}") }
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
