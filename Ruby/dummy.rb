require "./util"
require "./game"
require "./playing_cards"

module Dummy
  class PlaceHolderEx < Game::PlaceHolder
    def redraw(view)
      super view
      @text_id ||= @board.new_id
      c = view.create("TextBlock", @text_id)
      c.move_to(@pos[0], @pos[1] + 5, @pos[2] + 1, false, 0)
      c.redraw(@children.size.to_s)
    end
  end

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
        f.pos = [-300 + i * 100, 0, 0]
        f.base = [0, 1, 0]
        @fields << f
      end
      @hands = Game::PlaceHolder.new(self, :hands)

      @cards = PlayingCard.make_cards(self)
      @cards.each do |c|
        c.move(@stack)
      end

      @state = :start

      @stack.pos = [-120, 0, 160]
      @stack.base = [0, 0.1, 0]
      @stack.slide = [0, 0.1, 0]

      @pile.pos = [120, 0, 160]
      @pile.base = [0, 0.1, 0]
      @pile.slide = [0, 0.1, 0]

      @hands.pos = [0, 0, -140]
      @hands.base = [0, 0.1, 0]
      @hands.slide = [90, 0, 0]
      @hands.layout_center = true
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
      raise "not movable #{card}" unless movable_to?(card, move_to)

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

    def movable?(card_id)
      card = _ids(card_id)

      return false if state != :playing

      return hands.children.include?(card)
    end

    def movable_to?(card_id, move_to_id)
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
        stack.children.last.move(hands)
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
