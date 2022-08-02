# Board
#  +- *CardPlace
#     +- * Card
# Token

# CardPlaceは、カラの場所をもてるかどうか（７並べのときみたいに)
# Cardは、カードを持てるか => L2
# Cardは、横向き、裏向きなどの状態をもつ
# Tokenは、個別のIDをもつか => L2

# テストケース
# - ポーカー
# - 7ならべ
# - ソリティア
# - Slay the Spire
# - MTG

module Game
  class InvalidManipulationException < Exception
  end

  class Board
    attr_reader :root
    attr_reader :entities # readonly

    def initialize
      @next_entity_id = 0
      @entities = {}
      @root = Entity.new(self, true)
    end

    def move_entity(entity, new_parent, idx = nil)
      return if new_parent == entity.parent # TODO 同じparentでもidxありなら移動可能にする
      raise InvalidManipulationException.new unless new_parent.board == self
      if entity.parent != nil
        entity.parent.instance_eval do
          @children.delete(entity)
        end
      end
      if new_parent != nil
        new_parent.instance_eval do
          idx ||= @children.size
          @children.insert(idx, entity)
        end
      end
      entity.instance_eval { @parent = new_parent }
    end

    def dump
      _dump_inner(0, render)
    end

    def _dump_inner(indent, data)
      indent_str = " " * (indent * 2)
      str = []
      data.map do |k, v|
        if k != :children && k != :cls
          str << "#{k}:#{v}"
        end
      end
      print indent_str + "#{data[:cls]} " + str.join(" ") + "\n"
      if data[:children]
        data[:children].map { |c| _dump_inner(indent + 1, c) }
      end
    end

    def render
      @root._render
    end

    def _add_entity(entity)
      id = @next_entity_id += 1
      @entities[id] = entity
      @root.children << entity
      id
    end
  end

  class Entity
    attr_reader :id, :board, :parent
    attr_reader :children # readonly
    attr_accessor :pos

    def initialize(board, is_root = false)
      @pos = [0, 0]
      @board = board
      @children = []
      if is_root
        @parent = nil
        @id = 0
      else
        @parent = board.root
        @id = board._add_entity(self)
      end
    end

    def move(new_parent)
      @board.move_entity(self, new_parent)
    end

    def _render
      out = { id: @id, **render, cls: self.class.name }
      if render_children? && !children.empty?
        out[:children] = @children.map { |c| c._render }
      end
      out
    end

    def render_children?
      true
    end

    def render
      {}
    end

    def redraw_all(view)
      redraw(view)
      children.each do |c|
        c.redraw_all(view)
      end
    end

    def redraw(view)
    end
  end

  class PlaceHolder < Entity
    attr_reader :name, :is_stack

    attr_accessor :slide

    def initialize(board, name, is_stack: false)
      super board
      @name = name
      @is_stack = is_stack
      @slide = [0, 0]
    end

    def render_children?
      !@is_stack
    end

    def render
      if @is_stack
        { name: @name, count: children.size }
      else
        { name: @name }
      end
    end

    def redraw(view)
      children.each.with_index do |c, i|
        c.pos = [pos[0] + slide[0] * i, pos[1] + slide[1] * i]
      end
    end
  end

  class Card < Entity
    attr_reader :kind

    def initialize(board, kind)
      super board
      @kind = kind
    end

    def render
      { kind: @kind }
    end
  end

  class Rule
  end
end
