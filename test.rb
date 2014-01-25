# encoding: utf-8

require 'json'

require './parser'
require './dictionary'

dict = HangulDictionary.instance

dict.add "먹으", [:verbo]
dict.add "달리", [:verbo]
dict.add "을" , [:jxosa]
dict.add "를" , [:jxosa]
dict.add "은" , [:jxosa]
dict.add "는" , [:jxosa]
dict.add "나" , [:substantivo]
dict.add "미역국" , [:substantivo]

hp = HangulParser.new "나는 미역국을 먹음."

res = hp.frazo(hp.hangul.full_range, 0)



