require "./util"
require "./game"
require "./playing_cards"

class PokerBoard < Game::Board
  attr_accessor :cur_player
  attr_accessor :state # :start, :drawing, :bet, :finished
  attr_reader :stack, :pile, :hands, :cards

  def initialize
    super
    @stack = Game::PlaceHolder.new(self, :stack, is_stack: true)
    @pile = Game::PlaceHolder.new(self, :pile, is_stack: true)
    @hands = (0..1).map { |i| Game::PlaceHolder.new(self, :"hands#{i}") }

    @cards = PlayingCard.make_cards(self)
    @cards.each do |c|
      c.move(@stack)
    end
    @cur_player = 0
    @state = :start

    @stack.pos = [-300, 0, 0]
    @stack.base = [0, 0.1, 0]
    @stack.slide = [0, 0.1, 0]
    @pile.pos = [300, 0, 0]
    @pile.base = [0, 0.1, 0]
    @pile.slide = [0, 0.1, 0]
    @hands[0].pos = [0, 0, -140]
    @hands[0].base = [0, 0.1, 0]
    @hands[0].slide = [90, 0, 0]
    @hands[0].layout_center = true
    @hands[1].pos = [0, 0, 140]
    @hands[1].base = [0, 0.1, 0]
    @hands[1].slide = [90, 0, 0]
    @hands[1].layout_center = true
  end

  def change_player
    @cur_player = 1 - @cur_player
  end
end

class PokerRule
  attr_reader :board, :hands, :stack, :cards, :pile

  def initialize(rand = Random.new)
    @rand = rand
    @board = PokerBoard.new
    @matcher = PokerMatcher.new
    @stack = @board.stack
    @hands = @board.hands
    @cards = @board.cards
    @pile = @board.pile
  end

  def play(cmd)
    self.send(:"_do_#{cmd.type}", cmd)
  end

  #=========================================
  # Process commands
  #=========================================

  def _do_start(cmd)
    validate_state(:start)
    5.times {
      draw(0)
      draw(1)
    }
    @board.cur_player = 0
    @board.state = :drawing
  end

  def _do_select(cmd)
    validate_state(:drawing)
    raise "not selectable #{card}" unless selectable?(cmd.card)

    card = _ids(cmd.card)
    card.selected = !card.selected
  end

  def _do_discard(cmd)
    validate_state(:drawing)
    hand = hands[cur_player]
    discading_cards = hand.children.select { |c| c.selected }
    discading_cards.each do |card|
      if card.selected
        card.selected = false
        card.move(pile)
      end
    end
    draw(@board.cur_player, discading_cards.size)
    if cur_player == 0
      @board.change_player
    else
      @board.state = :bet
    end
  end

  def _do_bet(cmd)
    validate_state(:bet)
    r1 = match(hands[0].children)
    r2 = match(hands[1].children)
    @board.state = :finished
    [r1, r2]
  end

  def _do_reset(cmd)
    cards.each do |c|
      c.move(stack)
      stack.children.shuffle!(@rand)
    end
    @board.state = :start
  end

  #=========================================
  # Status
  #=========================================

  def selectable?(card_id)
    if state == :drawing
      card = @board.entities[card_id]
      hands[cur_player].children.include?(card)
    else
      false
    end
  end

  def movable?(card_id)
    return false
  end

  def movable_to?(card_id, move_to_id)
    return false
  end

  def trigger?(trigger)
    trigger = trigger.intern

    return true if trigger == :reset

    case state
    when :start
      trigger == :start
    when :drawing
      trigger == :discard
    when :bet
      trigger == :bet
    else
      false
    end
  end

  #=========================================
  # Utilities
  #=========================================

  def state
    @board.state
  end

  def cur_player
    @board.cur_player
  end

  def validate_state(*state_list)
    raise "Invalid state #{@board.state}" unless state_list.include?(@board.state)
  end

  def _ids(ids)
    if ids.is_a?(Array)
      ids.map { |id| @board.entities[id] }
    else
      @board.entities[ids]
    end
  end

  def validate_owner(player_idx, card)
    raise "Player #{player_idx} is not owner of #{card}" unless owner?(player_idx, card)
  end

  def owner?(player_idx, card)
    card.parent == @hands[player_idx]
  end

  def draw(player_idx, num = 1)
    num.times do
      @board.stack.children.first.move(@board.hands[player_idx])
    end
  end

  def match(cards)
    @matcher.match(cards)
  end
end

class PokerMatcher
  HANDS_ORDER = [:pair, :two_pairs, :threecards, :straight, :flush, :fullhouse, :straight_flush, :fourcards, :fivecards]

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
      if g[1][1] == 2
        [:fullhouse, [power_of_number]]
      else
        [:threecards, [power_of_number]]
      end
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
