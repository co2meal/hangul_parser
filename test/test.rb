# encoding: utf-8

require 'json'
require 'test/unit'
require 'pp'

require './parser'
require './dictionary'

class TestSimpleNumber < Test::Unit::TestCase
  def setup

    @dict = HangulDictionary.instance

    @dict.add "먹으", [:verbo]
    @dict.add "달리", [:verbo]
    @dict.add "을" , [:jxosa]
    @dict.add "를" , [:jxosa]
    @dict.add "은" , [:jxosa]
    @dict.add "는" , [:jxosa]
    @dict.add "나" , [:substantivo]
    @dict.add "너" , [:substantivo]
    @dict.add "미역국" , [:substantivo]


  end

  def test_1
    hp = HangulParser.new "나는 미역국을 먹음."
    res = hp.frazo(hp.hangul.full_range, 0)[1]

    pp res

    assert_equal(:frazo, res[0])
    assert_equal(:substantivo, res[1][0])
    assert_equal(:verbo, res[1][1][0])
    assert_equal(:jxosa, res[1][1][1][0])
    assert_equal(:jxosa, res[1][1][2][0])
    assert(!res[1][1][3][0][0].is_a?(Symbol))
  end

  def test_2
    hp = HangulParser.new "나는 너의 미역국을 먹음."
    res = hp.frazo(hp.hangul.full_range, 0)

    pp res
  end


end


