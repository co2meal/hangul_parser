require 'singleton'
require './hangul'

class HangulDictionary < Hash
  include Singleton
  def add(string, array)
    self[string] = array
    # self[Hangul.new(string).splitted] = array
  end
end
