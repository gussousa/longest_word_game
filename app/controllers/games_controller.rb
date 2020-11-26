require 'json'
require 'open-uri'

class GamesController < ApplicationController
  def new
    def get_letters
      all_letters = ('a'..'z').to_a
      picked_letters = []
      10.times { picked_letters << all_letters[rand(all_letters.length)].upcase }
      picked_letters
    end
    @letters = get_letters
  end

  def score
    return if params[:word].nil?

    @word = params[:word].upcase
    @letters = params[:letters]
    return unless @word.length.positive?

    @wrong = verify_word_in_grid(@word, @letters)
    @word_validation = verify_word_in_api(@word)
    return unless @wrong.length.zero? && @word_validation

    @score = get_score(@word)
  end

  private

  def get_score(word)
    special_letters = %w[z q j h x]
    score = word.chars.length
    special_letters.each { |letter| score += 3 if word.include?(letter.upcase) }
    session[:high_scores].nil? ? session[:high_scores] = [[score, word]] : session[:high_scores] << [score, word]
    score
  end

  def verify_word_in_api(word)
    url = "https://wagon-dictionary.herokuapp.com/#{word}"
    word_serialized = open(url).read
    result = JSON.parse(word_serialized)
    result['found']
  end

  def verify_word_in_grid(word, letters)
    wrong = []
    word.chars.each do |letter|
      control = wrong.include?(letter)
      wrong << letter unless letters.include?(letter) && letters.count(letter) >= word.count(letter) || control
    end
    wrong
  end
end
