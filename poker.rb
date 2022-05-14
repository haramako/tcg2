class Poker
  attr_reader :board, :hands, :stack, :cards

  def initialize
    @board = Game::Board.new
    @stack = Game::Entity.new(@board)
    @hands = (0..1).map { |i| Game::Entity.new(@board) }
    @cards = PlayingCard.make_cards(@board)
    @matcher = PokerMatcher.new

    @cards.each do |c|
      c.move(@stack)
    end
  end

  def find_card(suit, number)
    @cards.find { |c| c.suit == suit && c.number == number }
  end

  def draw(player_idx, i)
    @board.stack.children[0].move(@hands[player_idx])
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
