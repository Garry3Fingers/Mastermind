# frozen_string_literal: true

require 'colorize'

# This module is used to start a new game
module PlayNewGame
  def new_game
    puts "\nDo you want to play again? Enter 'yes' or whatever"
    input = gets.chomp

    if input.downcase == 'yes'
      StartGame.new
    else
      puts "\nThanks for playing!"
    end
  end
end

# Base class for the game
class GameBoard
  attr_reader :colors

  include PlayNewGame

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

    puts "\nThe codebreaker has broke the code!"
    true
  end

  def guess_feedback(code, guess_code)
    code.each_with_index.map do |_, index|
      if black_test(code[index], guess_code[index])
        1
      elsif white_test(code, guess_code, guess_code[index], index)
        2
      else
        3
      end
    end
  end

  def white_test(code, guess_code, position, index)
    if guess_code.count(position) == 1 && code.include?(position)
      true
    elsif white_additional_test(code, guess_code, position)
      true
    elsif white_additional_test2(code, guess_code, position, index)
      true
    end
  end

  def white_additional_test(code, guess_code, position)
    return unless guess_code.count(position) > 1 && code.include?(position)\
       && guess_code.count(position) == code.count(position)

    true
  end

  def white_additional_test2(code, guess_code, position, index)
    return unless guess_code.count(position) > 1 && code.count(position) > 1\
       && guess_code.count(position) > code.count(position)\
       && check(code, guess_code, position) != code.count(position) && index != guess_code.rindex(position)

    true
  end

  # This is an additional check for a black peg
  def check(code, guess_code, position)
    check = code.each_with_index.map do |_, i|
      next if guess_code[i] != position

      1 if black_test(code[i], guess_code[i])
    end
    check.count(1)
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
placed in the wrong position. Red is the wrong color.\n\n"
    puts "#{guess_arr[0]} #{guess_arr[1]} #{guess_arr[2]} #{guess_arr[3]}\n\n"
  end
end

class InvalidInput < StandardError; end

# This class contains methods for the codebreaker player role.
class PlayerCodebreaker < GameBoard
  private

  def computer_make_code
    @colors.sample(4)
  end

  def while_loop(code)
    i = 8

    while i.positive?
      guess_code = player_make_guess

      break if compare_arr(code, guess_code)

      puts "\nThe player has #{i} attempts to break the code!"

      show_guess_feedback(code, guess_code)

      i -= 1
    end

    puts 'The player didn\'t break the code. Computer wins!' if i.zero?
    puts "\nThe code was: #{code[0]} #{code[1]} #{code[2]} #{code[3]}" if i.zero?
  end

  public

  def player_loop
    code = computer_make_code

    while_loop(code)

    new_game
  end
end

# This class contains methods for the codemaker player role.
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

  def while_loop(code)
    i = 8

    while i.positive?
      puts "The computer has #{i} attempts to break the code!\n\n"

      guess_code = choose_code(i, code, guess_code)

      puts "Guess: #{guess_code[0]} #{guess_code[1]} #{guess_code[2]} #{guess_code[3]}\n\n"

      break if compare_arr(code, guess_code)

      show_guess_feedback(code, guess_code)

      i -= 1
    end

    puts 'The computer didn\'t break the code. Player wins!' if i.zero?
  end

  public

  def computer_loop
    code = player_make_guess

    while_loop(code)

    new_game
  end
end

# Class for game mode selection
class StartGame
  def initialize
    puts show_start_message
    puts 'Choose you role! Enter 1 for codebreaker and 2 for codemaker.'
    input = player_input

    if input == 1
      PlayerCodebreaker.new.player_loop
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
within eight turns.\n\n"
  end
end

StartGame.new
