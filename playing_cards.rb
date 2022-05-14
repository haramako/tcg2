class PlayingCard < Game::Entity
  attr_reader :suit, :number, :name

  SUITS = [:heart, :spade, :crover, :dia]

  SUIT_NAME = {
    heart: "H",
    spade: "S",
    crover: "C",
    dia: "D",
  }

  POWER_OF_NUMBER = [nil, 14, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13]
  POWER_OF_SUIT = {
    heart: 0,
    crover: 1,
    dia: 2,
    spade: 3,
  }

  NUMBER_NAMES = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "J", "Q", "K"]

  def initialize(board, suit, number)
    super board
    @suit = suit
    @number = number
    @name = "#{SUIT_NAME[@suit]}#{number}"
  end

  def render
    { kind: name }
  end

  def to_s
    @name
  end

  def inspect
    @name
  end

  def power_of_number
    POWER_OF_NUMBER[@number]
  end

  def power_of_suit
    POWER_OF_SUIT[@suit]
  end

  def self.make_cards(board)
    cards = []
    SUITS.each do |suit|
      (1..13).each do |n|
        cards << PlayingCard.new(board, suit, n)
      end
    end
    cards
  end
end
