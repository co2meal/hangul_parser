# encoding: utf-8

require 'json'
require 'memoize'
require './hangul'
require './dictionary'

class HangulParser
	include Memoize

  def initialize hangul
  	unless hangul.is_a? Hangul
	  	hangul = Hangul.new hangul
	  end

    @hangul = hangul

    memoize :frazo
    memoize :substantivo
    memoize :verbo
    memoize :jxosa
  end

  def hangul
  	@hangul
  end

  def dict
  	HangulDictionary.instance
  end

  def frazo r, k
    candidates = [[999999, :fail_frazo]]
    hangul.splitted(r, k).reverse_each do |ch|
      if ch == "."
      	value = 1 + substantivo(r.first..r.last-1, 0)[0]
      	lisp = [:frazo, substantivo(r.first..r.last-1, 0)[1], "."]
        candidates.push [value, lisp]
      end
    end

    puts JSON.pretty_generate ['frazo', r, candidates.min]

    return candidates.min
  end

  def substantivo r, k
    candidates = [[999999, :fail_substantivo]]

    if vorto = dict[hangul.string(r)] and vorto.include? :substantivo
    	value = 1
    	lisp = [:substantivo, hangul.splitted(r,k)]
      candidates.push [value, lisp]
    end

    if hangul.splitted(r.last, k)[2] == "ㅁ"
    	value = 1 + verbo(r.first..r.last, 1)[0]
    	lisp = [:substantivo, verbo(r.first..r.last, 1)[1], "ㅁ"]
      candidates.push [value, lisp]
    end

    puts 'substantivo'
    puts JSON.pretty_generate hangul.splitted(r, k)
    puts JSON.pretty_generate candidates.min


    return candidates.min
  end

  def verbo r, k
    candidates = [[999999, :fail_verbo]]
    return candidates.min if r.count == 0

    if vorto = dict[hangul.string(r,k)] and vorto.include? :verbo
    	value = 1
    	lisp = [:verbo, hangul.splitted(r,k)]
    	candidates.push [value, lisp]
    end

    r.each do |i|
    	if hangul.splitted(r, k)[i-r.first] == " "
	    	value = 1 + jxosa(r.first..i-1, 0)[0] + verbo(i+1..r.last, k)[0]
	    	lisp = [:verbo, jxosa(r.first..i-1, 0)[1]] + verbo(i+1..r.last, k)[1][1..-1]

		    candidates.push [value, lisp]
	    end
    end

    puts 'verbo'
    puts JSON.pretty_generate hangul.splitted(r, k)
    puts JSON.pretty_generate candidates.min
    return candidates.min
  end

  def jxosa r, k
    candidates = [[999999, [:fail_jxosa]]]
    return candidates.min if r.count == 0

    if vorto = dict[hangul.string(r.last)] and vorto.include? :jxosa

    	value = 1 + substantivo(r.first..r.last-1, 0)[0]
    	lisp = [:jxosa, substantivo(r.first..r.last-1, 0)[1], hangul.splitted(r.last)]

	    candidates.push [value, lisp]

    end
    puts 'jxosa'
    puts JSON.pretty_generate hangul.splitted(r)
    puts JSON.pretty_generate candidates
    return candidates.min
  end
end

