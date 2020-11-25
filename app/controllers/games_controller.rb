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
    @word = params[:word].upcase
    @letters = params[:letters]
    @wrong = []

    return unless @word.length.positive?

    @word.chars.each do |letter|
      @wrong << letter unless @letters.include?(letter) || @wrong.include?(letter)
    end
    url = "https://wagon-dictionary.herokuapp.com/#{@word}"
    word_serialized = open(url).read
    word = JSON.parse(word_serialized)
    @word_validation = word['found']

    return unless @wrong.length.zero? && @word_validation

    special_letters = ['z', 'q', 'x', 'h']
    @score = @word.chars.length**2
  end
end
