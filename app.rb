require "./game"
require "./playing_cards"
require "./poker"

def make_cmd(name, *rest)
  r = Struct.new(name, *rest)
  r.define_method(:type) do name.downcase end
  return r
end

module Cmd
  Start = make_cmd("Start")
  Select = make_cmd("Select", :card)
  Discard = make_cmd("Discard")
end

module EntryPoint
  def self.run(view)
    game = PokerRule.new
    game.play(Cmd::Start[])
    #game.board.root.redraw_all(view)
    game
  end
end

#EntryPoint.run(nil)
