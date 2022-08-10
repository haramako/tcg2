require "./game"
require "./playing_cards"

class Array
  def shuffle(rand = Random)
    self.clone.shuffle!(rand)
  end

  def shuffle!(rand = Random)
    len = self.size
    len.times do |n|
      idx = rand.rand(self.size - n)
      self[idx], self[len - n - 1] = self[len - n - 1], self[idx]
    end
    self
  end
end

module Dummy
  class DummyBoard < Game::Board
    attr_accessor :state # :start, :drawing, :bet, :finished
    attr_reader :stack, :pile, :hands, :cards, :fields

    def initialize
      super
      @stack = Game::PlaceHolder.new(self, :stack, is_stack: true)
      @pile = Game::PlaceHolder.new(self, :pile, is_stack: true)
      @fields = []
      7.times do |i|
        f = Game::PlaceHolder.new(self, :"field#{i}")
        f.pos = [-400 + i * 130, 0]
        @fields << f
      end
      @hands = Game::PlaceHolder.new(self, :hands)

      @cards = PlayingCard.make_cards(self)
      @cards.each do |c|
        c.move(@stack)
      end

      @state = :start

      @stack.pos = [-300, 200]
      @stack.slide = [-1, 1]

      @pile.pos = [300, 200]

      @hands.pos = [-400, -240]
      @hands.slide = [110, 0]
    end
  end

  class DummyRule
    attr_reader :board, :hands, :stack, :cards, :pile, :fields

    def initialize(rand = Random.new)
      @rand = rand
      @board = DummyBoard.new
      @stack = @board.stack
      @hands = @board.hands
      @cards = @board.cards
      @pile = @board.pile
      @fields = @board.fields

      reset
    end

    def state
      @board.state
    end

    def play(cmd)
      self.send(:"_do_#{cmd.type}", cmd)
    end

    #=========================================
    # Process commands
    #=========================================

    def _do_start(cmd)
      validate_state(:start)
      draw(7)
      @board.state = :playing
    end

    def _do_move(cmd)
      validate_state(:playing)
      card = _ids(cmd.card)
      move_to = _ids(cmd.move_to)
      raise "not movable #{card}" unless movable?(card, move_to)

      card.move(move_to)

      discard_cards = []
      (0...fields.size - 1).each do |n|
        next if fields[n].children.empty? || fields[n + 1].children.empty?
        if fields[n][0].number == fields[n + 1][0].number
          discard_cards << fields[n][0]
          discard_cards << fields[n + 1][0]
        end
      end
      discard_cards.uniq.each do |c|
        c.move(pile)
      end

      unless stack.empty?
        draw(1)
      end
    end

    def _do_reset(cmd)
      reset
    end

    #=========================================
    # Status
    #=========================================

    def reset
      cards.each do |c|
        c.move(stack)
        stack.children.shuffle!(@rand)
      end
      @board.state = :start
    end

    def selectable?(card_id)
      if state == :drawing
        card = @board.entities[card_id]
        hands[cur_player].children.include?(card)
      else
        false
      end
    end

    def movable?(card_id, move_to_id)
      card = _ids(card_id)
      move_to = _ids(move_to_id)

      return false if state != :playing

      return fields.include?(move_to) && move_to.children.size <= 0
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

    def validate_state(*state_list)
      raise "Invalid state #{@board.state}" unless state_list.include?(@board.state)
    end

    def _ids(ids)
      if ids.is_a?(Game::Entity)
        ids
      elsif ids.is_a?(Array)
        ids.map { |id| _ids[id] }
      else
        @board.entities[ids]
      end
    end

    def draw(num = 1)
      num.times do
        stack.children.first.move(hands)
      end
    end
  end

  #=========================================
  # Commands for Test
  #=========================================
  module Cmd
    def self.make_cmd(name, *rest)
      r = Struct.new(name, *rest)
      r.define_method(:type) do name.downcase end
      return r
    end

    Start = make_cmd("Start")
    Move = make_cmd("Move", :card, :move_to)
    Reset = make_cmd("Reset")
  end
end
