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

  def computer_make_code
    @colors.sample(4)
  end

  def player_make_guess
    puts "Choose four colors from the 'Red, Blue, Green, Yellow, Orange, Purple' list."
    puts "Press 'Enter' after each selection."
    player_guess = []
    4.times do
      player_guess << player_input
    end
    player_guess
  end

  def compare_arr(code, guess_code)
    return unless guess_code == code

    puts 'Gongratulations! You broke the code!'
    true
  end

  def guess_feedback(code, guess_code)
    check = false
    code.each_with_index.map do |_, i|
      if code[i] == guess_code[i]
        'O'.colorize(:red)
      elsif guess_code.count(guess_code[i]) == 1 && code.include?(guess_code[i])
        'O'.colorize(:light_white)
      elsif guess_code.count(guess_code[i]) > 1 && check == false && code.include?(guess_code[i])
        check = true
        'O'.colorize(:light_white)
      else
        'O'.colorize(:black)
      end
    end
  end

  public

  def game_loop
    code = computer_make_code
    i = 12
    while i.positive?
      puts "You left #{i} attempts to break the code!"
      guess_code = player_make_guess
      break if compare_arr(code, guess_code)

      puts guess_feedback(code, guess_code)
      i -= 1
    end
    puts 'Game over!'
  end
end

class InvalidInput < StandardError; end

game_board = GameBoard.new

# p String.colors
game_board.game_loop
