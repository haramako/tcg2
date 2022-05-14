class PokerBoard < Game::Board
  attr_accessor :cur_player, :state
  attr_reader :stack, :pile, :hands, :cards

  def initialize
    super
    @stack = Game::PlaceHolder.new(self, :stack, is_stack: true)
    @pile = Game::PlaceHolder.new(self, :pile, is_stack: true)
    @hands = (0..1).map { |i| Game::PlaceHolder.new(self, :"hands#{i}") }
    @cards = PlayingCard.make_cards(self)
    @cur_player = 0
    @state = :start
  end

  def change_player
    @cur_player = 1 - @cur_player
  end
end

class PokerRule
  attr_reader :board, :hands, :stack, :cards, :pile

  def initialize
    @board = PokerBoard.new
    @stack = @board.stack
    @pile = @board.pile
    @hands = @board.hands
    @cards = @board.cards
    @matcher = PokerMatcher.new

    @cards.each do |c|
      c.move(@stack)
    end
  end

  def play(cmd)
    self.send(:"_do_#{cmd[:type]}", cmd)
  end

  def _do_start(cmd)
    5.times {
      draw(0)
      draw(1)
    }
    @board.cur_player = 0
    @board.state = :drawing
  end

  def _do_discard(cmd)
    check_state(:drawing)
    cards = _ids(cmd[:cards])
    cards.each do |card|
      must_owner(board.cur_player, card)
      card.move(@pile)
    end
    draw(@board.cur_player, cards.size)
    if @board.cur_player == 0
      @board.change_player
    else
      @board.state = :bet
    end
  end

  def _do_reset(cmd)
    @cards.each do |c|
      c.move(@stack)
    end
  end

  def check_state(*state_list)
    raise "Invalid state #{@board.state}" unless state_list.include?(@board.state)
  end

  def _ids(ids)
    ids.map { |id| @board.entities[id] }
  end

  def must_owner(player_idx, card)
    raise "Player #{player_idx} is not owner of #{card}" unless owner?(player_idx, card)
  end

  def owner?(player_idx, card)
    card.parent == @hands[player_idx]
  end

  def draw(player_idx, num = 1)
    num.times do
      @stack.children.first.move(@hands[player_idx])
    end
  end

  def match(cards)
    @matcher.match(cards)
  end
end

class PokerMatcher
  HANDS_ORDER = [:pair, :two_pairs, :threecards, :straight, :flush, :straight_flush, :fourcards, :fivecards]

  def initialize
  end

  def match_x(cards)
    match_pairs(cards)
  end

  def match(cards)
    r = []
    r << match_flush(cards)
    r << match_straight(cards)
    if r[0] && r[1]
      r << [:straight_flush, r[0][1]]
    end
    r << match_pairs(cards)
    r.delete(nil)
    if r.size > 0
      r.max_by { |x| HANDS_ORDER.find_index(x[0]) }
    else
      nil
    end
  end

  def match_flush(cards)
    g = cards.group_by { |c| c.suit }.sort_by { |k, v| -v.size }
    if g[0][1].size == 5
      [:flush, [g[0][1][0].power_of_suit]]
    else
      nil
    end
  end

  def match_straight(cards)
    g = cards.sort_by { |c| c.number }
    base_number = g[0].number - 1
    if g.all? { |c| c.number == (base_number += 1) }
      [:straight, [g[4].power_of_number, g[4].power_of_suit]]
    else
      nil
    end
  end

  def match_pairs(cards)
    g = cards.group_by { |c| c.number }.map { |k, v| [k, v.size, v] }.sort_by { |k, v, c| [-v, -PlayingCard::POWER_OF_NUMBER[k]] }
    power_of_number = g[0][0]
    if g[0][1] == 5
      [:fivecards, [power_of_number]]
    elsif g[0][1] == 4
      [:fourcards, [power_of_number]]
    elsif g[0][1] == 3
      [:threecards, [power_of_number]]
    elsif g[0][1] == 2
      power_of_suit = g[0][2].max_by { |c| c.power_of_suit }.power_of_suit
      if g[1][1] == 2
        [:two_pairs, [power_of_number, power_of_suit]]
      else
        [:pair, [power_of_number, power_of_suit]]
      end
    else
      nil
    end
  end
end
