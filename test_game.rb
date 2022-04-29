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
  assert_equal(1, h[0].cards.size)
  assert_equal(0, h[1].cards.size)
  assert_equal(c[0], h[0].cards[0])

  c[0].move(h[1])
  assert_equal(0, h[0].cards.size)
  assert_equal(1, h[1].cards.size)
  assert_equal(c[0], h[1].cards[0])

  puts
  puts b.dump
end
