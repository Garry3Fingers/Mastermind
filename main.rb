# frozen_string_literal: true

require 'colorize'

# It's a test class
class GameBoard
  attr_reader :colors

  def initialize
    @colors = %w[red blue green yellow orange purple]
  end

  private

  def player_input
    input = gets.chomp
    raise InvalidInput, 'Invalid color. Please enter the color from the list' unless @colors.include?(input.downcase)
  rescue InvalidInput => e
    puts e
    retry
  else
    input.downcase
  end

  public

  def pc_make_code
    @colors.rotate(rand(1..100))[0, 4]
  end

  def player_make_guess
    puts "Choose four colors from the 'Red, Blue, Green, Yellow, Orange, Purple' list."
    puts "Press 'Enter' after each selection."
    player_guess = []
    4.times do
      player_guess << player_input
    end
  end
end

class InvalidInput < StandardError; end

game_board = GameBoard.new

p game_board.pc_make_code

game_board.player_make_guess
