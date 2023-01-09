class GameBoard
  attr_reader :colors

  def initialize
    @colors = %w[red blue green yellow orange purple]
  end

  def pc_make_code
    @colors.rotate(rand(1..100))[0, 4]
  end
end

game_board = GameBoard.new

p game_board.pc_make_code
