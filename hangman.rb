require 'yaml'

class Hangman

  def dictionary
    File.open("5desk.txt", "r").readlines.select do |word|
      word.length >= 5 && word.length <= 12
    end
  end

  def initialize
    puts "|-----------------------------|"
    puts "|*****Welcome to Hangman!*****|"
    puts "|A word has been chosen from a|"
    puts "|dictionary. Guess the letters|"
    puts "|in the word before you run   |"
    puts "|out of chances(10).           |"
    puts "|-----------------------------|"
    intro
  end

  def intro
    puts "|(n)ew game                   |"
    puts "|(l)oad saved game            |"
    puts "|(q)uit                       |"
    user_input
  end

  def user_input
    input = gets.chomp.downcase
    if input == 'n'
      new_game
    elsif input == 'l'
      load_game
    elsif input == 'q'
      quit
    else
      puts "|Invalid input. Try again.    |"
      puts "|-----------------------------|"
      intro
    end
  end

  def new_game
    @word = generate_word
    @guessed = []
    @secret = hide_word
    @chances = 10
    play
  end

  def save_game
    Dir.mkdir("saves") unless Dir.exists?("saves")
    File.open("saves/saved.yaml", "w") do |file|
      file.write(YAML::dump(self))
    end
    puts "|Game saved!                  |"
  end

  def load_game
    if File.exists?("saves/saved.yaml")
      saved_game = YAML::load(File.read("saves/saved.yaml"))
      puts "|Loading saved game...        |"
      saved_game.play
    else
      puts "|-----------------------------|"
      puts "|No saved games exist.        |"
      puts "|Going back to main menu.     |"
      puts "|-----------------------------|"
      intro
    end
  end

  def quit
    puts "|Have a nice day!!            |"
    puts "|-----------------------------|"
    exit
  end

  def generate_word
    dictionary.sample.chomp
  end

  def hide_word
    @word.split("").map { |c| c = "-" }
  end

  def play
    puts "|-----------------------------|"
    puts '|You can enter: "menu", "save"|'
    puts '|or "quit" at any time.       |'
    puts "|Enter a guess:               |"
    while @chances > 0

      puts add_spaces(@secret.join(" "))
      puts "|Letters used:                |"
      puts add_spaces(@guessed.join(","))
      puts "|                             |"
      temp = "Chances remaining: " + @chances.to_s
      puts add_spaces(temp)
      puts "|Enter a letter:              |"
      check_input
    end
    game_over
  end

  def check_input
    guess = gets.chomp.downcase
    if guess == "save"
      save_game
    elsif guess == "quit"
      quit
    elsif guess == "menu"
      intro
    elsif guess =~ /[a-z]/ && guess.length == 1
      check_guesses(guess)
    else
      puts "|Invalid input. Try again.    |"
      check_input
    end
  end

  def check_guesses(guess)
    if @guessed.include?(guess) || @secret.include?(guess)
      temp = "Already tried '#{guess}'. Try again."
      puts add_spaces(temp)
    else
      check_word(guess)
    end
  end

  def check_word(guess)
    (0..@word.length-1).each do |i|
      @secret[i] = guess if @word[i] == guess
    end
    if @word.include?(guess)
      puts "|#{guess} is a good guess!           |"
      check_win
    else
      puts "|#{guess} is not in the word.        |"
      @guessed << guess
      @chances -= 1
    end
  end

  def check_win
    if @secret.join("") == @word
      puts "|*********YOU WIN!!!!*********|"
      puts "|The word was:                |"
      puts add_spaces(@word)
      puts "|-----------------------------|"
      intro
    end
  end

  def game_over
    puts "|**********YOU LOSE!**********|"
    puts "|The word was:                |"
    puts add_spaces(@word)
    puts "|-----------------------------|"
    intro
  end

  def add_spaces(str)
    str = "|" +  str
    while str.length < 30
      str += " "
    end
    str += "|"
  end
end

Hangman.new
