require "./game"
require "./playing_cards"
require "./poker"

module EntryPoint
  def self.run(view)
    game = PokerRule.new
    game.play(type: :start)
    game.board.root.redraw_all(view)
    game
  end
end
