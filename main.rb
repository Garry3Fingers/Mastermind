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
        1
      elsif white_test(code, guess_code, guess_code[i], i)
        2
      else
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
    code == guess_code
  end

  def colorize_feedback(code, guess_code)
    guess_feedback(code, guess_code).sort.map do |number|
      case number
      when 1
        'O'.colorize(:black)
      when 2
        'O'.colorize(:light_white)
      when 3
        'O'.colorize(:red)
      end
    end
  end

  def show_guess_feedback(code, guess_code)
    guess_arr = colorize_feedback(code, guess_code)

    puts "\nBlack is the correct color in both color and position. White is the correct color
placed in the wrong position. Red is the wrong color.
\n"
    puts "#{guess_arr[0]} #{guess_arr[1]} #{guess_arr[2]} #{guess_arr[3]}
    \n"
  end
end

class InvalidInput < StandardError; end

class PlaylerCodebreaker < GameBoard
  private

  def computer_make_code
    @colors.sample(4)
  end

  public

  def player_loop
    code = computer_make_code
    i = 8
    while i.positive?
      guess_code = player_make_guess
      break if compare_arr(code, guess_code)

      puts "You left #{i} attempts to break the code!"

      show_guess_feedback(code, guess_code)
      i -= 1
    end
    puts 'Game over! You have no attempts left!' if i.zero?
  end
end

class PlayerCodemaker < GameBoard
  attr_accessor :set_of_s

  def initialize
    super
    @set_of_s = []
  end

  private

  def combinations
    @colors.repeated_permutation(4) { |permutation| @set_of_s << permutation }
    @set_of_s
  end

  def computer_first_guess(combination_arr)
    index = combination_arr.index { |arr| arr == %w[red red blue blue] }
    combination_arr[index]
  end

  def process_feedback(feedback, guess)
    @set_of_s.reject! do |arr|
      arr unless reduce(feedback, guess, arr, 1) && reduce(feedback, guess, arr, 2)
    end.sample
  end

  def reduce(feedback, guess, arr, number)
    guess_feedback(arr, guess).count { |elem| elem == number } == feedback.count { |elem| elem == number }
  end

  def choose_code(iteration, code, guess_code)
    if iteration == 8
      computer_first_guess(combinations)
    else
      process_feedback(guess_feedback(code, guess_code), guess_code)
    end
  end

  public

  def computer_loop
    code = player_make_guess
    i = 8
    while i.positive?
      puts "You left #{i} attempts to break the code!"

      guess_code = choose_code(i, code, guess_code)

      break if compare_arr(code, guess_code)

      show_guess_feedback(code, guess_code)

      i -= 1
    end
    puts 'Game over! You have no attempts left!' if i.zero?
  end
end

class StartGame
  def initialize
    puts show_start_message
    puts 'Choose you role! Enter 1 for codebreaker and 2 for codemaker.'
    input = player_input

    if input == 1
      PlaylerCodebreaker.new.player_loop
    else
      PlayerCodemaker.new.computer_loop
    end
  end

  private

  def player_input
    input = gets.chomp
    raise InvalidInput, 'Invalid number. Please enter 1 or 2' unless input.to_i == 1 || input.to_i == 2
  rescue InvalidInput => e
    puts e
    retry
  else
    input.to_i
  end

  def show_start_message
    "Mastermind is a code-breaking game for two players. One player becomes the codemaker, the other the codebreaker.
The codemaker chooses a pattern of four colors. The codebreaker tries to guess the pattern, in both order and color,
within eight turns.
\n"
  end
end

StartGame.new
