require "./game"
require "./playing_cards"
require "./poker"

module EntryPoint
  def self.run(board)
    c1 = board.create("Card", 1)
    c1.moveto(100, 100, 1.0)
  end
end
