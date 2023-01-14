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
    code.each_with_index.map do |_, i|
      if black_test(code[i], guess_code[i])
        'O'.colorize(:black)
      elsif white_test(code, guess_code, guess_code[i], i)
        'O'.colorize(:light_white)
      else
        'O'.colorize(:red)
      end
    end
  end

  def white_test(code, guess_code, position, index)
    if guess_code.count(position) == 1 && code.include?(position)
      true
    elsif guess_code.count(position) > 1 && code.include?(position) && guess_code.index(position) == guess_code[index]
      true
    end
  end

  def black_test(code, guess_code)
    return unless code == guess_code

    true
  end

  def show_guess_feedback(code, guess_code)
    guess_arr = guess_feedback(code, guess_code)
    puts "Black is the correct color in both color and position. White is the correct color
placed in the wrong position. Red is the wrong color."
    puts "#{guess_arr[0]} #{guess_arr[1]} #{guess_arr[2]} #{guess_arr[3]}"
  end

  public

  def game_loop
    code = computer_make_code
    i = 12
    while i.positive?
      puts "You left #{i} attempts to break the code!"
      guess_code = player_make_guess
      break if compare_arr(code, guess_code)

      show_guess_feedback(code, guess_code)
      i -= 1
    end
    puts 'Game over!'
  end
end

class InvalidInput < StandardError; end

game_board = GameBoard.new

# p String.colors
game_board.game_loop
