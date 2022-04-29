# Board
#  +- *CardPlace
#     +- * Card
# Token

# CardPlaceは、カラの場所をもてるかどうか（７並べのときみたいに)
# Cardは、カードを持てるか
# Cardは、横向き、裏向きなどの状態をもつ
# Tokenは、個別のIDをもつか

module Game
  class Board
    attr_reader :cards, :places # readonly

    def initialize
      @next_place_id = 0
      @next_card_id = 0
      @places = {}
      @cards = {}
    end

    def add_place(place)
      id = @next_place_id += 1
      @places[id] = place
      id
    end

    def add_card(card)
      id = @next_card_id += 1
      @cards[id] = card
      id
    end

    def move_card(card, new_place, idx = nil)
      return if new_place == card.place
      raise unless new_place.board == self
      if card.place != nil
        card.place.instance_eval do
          @cards.delete(card)
        end
      end
      if new_place != nil
        new_place.instance_eval do
          idx ||= @cards.size
          @cards.insert(idx, card)
        end
      end
      card.instance_eval { @place = new_place }
    end

    def dump
      @places.map { |id, p| "#{id}: #{p.name}\n  #{p.dump}" }.join("\n")
    end
  end

  class CardPlace
    attr_reader :id, :name, :board
    attr_reader :cards # readonly

    def initialize(board, name)
      @name = name
      @board = board
      @id = board.add_place(self)
      @cards = []
    end

    def dump
      @cards.map { |c| c.dump }.join(" ")
    end
  end

  class Card
    attr_reader :id, :board, :place, :kind

    def initialize(board, kind)
      @board = board
      @place = nil
      @id = board.add_card(self)
      @kind = kind
    end

    def move(new_place)
      @board.move_card(self, new_place)
    end

    def dump
      "(#{@id} #{@kind})"
    end
  end
end
