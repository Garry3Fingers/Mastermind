# frozen_string_literal: true

require 'colorize'

# It's a test class
class GameBoard
  attr_reader :colors
  attr_accessor :set_of_s

  def initialize
    @colors = %w[red blue green yellow orange purple]
    @set_of_s = []
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
    puts "\nChoose four colors from the 'Red, Blue, Green, Yellow, Orange, Purple' list."
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
        # 'O'.colorize(:black)
        1
      elsif white_test(code, guess_code, guess_code[i], i)
        # 'O'.colorize(:light_white)
        2
      else
        # 'O'.colorize(:red)
        3
      end
    end
  end

  def white_test(code, guess_code, position, index)
    if guess_code.count(position) == 1 && code.include?(position)
      true
    elsif guess_code.count(position) > 1 && code.include?(position) && guess_code.index(position) == index\
      &&  black_test(code[guess_code.rindex(position)], guess_code[guess_code.rindex(position)]) == false
      true
    end
  end

  def black_test(code, guess_code)
    # return unless code == guess_code

    # true
    code == guess_code
  end

  def show_guess_feedback(code, guess_code)
    guess_arr = guess_feedback(code, guess_code)
    puts "\nBlack is the correct color in both color and position. White is the correct color
placed in the wrong position. Red is the wrong color.
\n"
    puts "#{guess_arr[0]} #{guess_arr[1]} #{guess_arr[2]} #{guess_arr[3]}
    \n"
  end

  public

  def show_start_message
    "Mastermind is a code-breaking game for two players. One player becomes the codemaker, the other the codebreaker.
The codemaker chooses a pattern of four colors. The codebreaker tries to guess the pattern, in both order and color,
within eight turns.
\n"
  end

  def game_loop
    code = computer_make_code
    i = 8
    while i.positive?
      puts "You left #{i} attempts to break the code!"
      guess_code = player_make_guess
      break if compare_arr(code, guess_code)

      show_guess_feedback(code, guess_code)
      i -= 1
    end
    puts 'Game over! You have no attempts left!' if i.zero?
  end

  def process_feedback(feedback, guess_code)
    feedback.each_with_index do |number, index|
      @set_of_s.reject! do |arr|
        case number
        when 1
          arr[index] != guess_code[index]
        when 2
          arr.include?(guess_code[index]) == false || arr.count(guess_code[index]) > 1
        when 3
          arr.count(guess_code[index]) > 1
        end
      end
    end

    @set_of_s.sample
  end

  def computer_loop
    code = computer_make_code
    i = 8
    while i.positive?
      puts "You left #{i} attempts to break the code!"

      guess_code = if i == 8
                     computer_first_guess(combinations)
                   else
                     process_feedback(guess_feedback(code, guess_code), guess_code)
                   end

      break if compare_arr(code, guess_code)

      p guess_feedback(code, guess_code)

      i -= 1
    end
    puts 'Game over! You have no attempts left!' if i.zero?
  end

  def combinations
    @colors.repeated_permutation(4) { |permutation| @set_of_s << permutation }
    @set_of_s
  end

  def computer_first_guess(combination_arr)
    index = combination_arr.index { |arr| arr == %w[red red blue blue] }
    combination_arr[index]
  end
end

class InvalidInput < StandardError; end

game_board = GameBoard.new

# p String.colors

game_board.computer_loop
