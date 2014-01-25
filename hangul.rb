# encoding: utf-8

require 'memoize'

class Hangul
  include Memoize

  def initialize(string)
    @string = string
    @splitted_hangul = hangul_split(string)
    memoize :splitted
  end

  def splitted(range = nil, k = 0)
    range = full_range unless range
    if k == 0
      res = @splitted_hangul[range]
    else
      res = @splitted_hangul[range].clone
      ch = res.pop.dup
      ch[2] = ' '
      res.push ch
    end

    return res.freeze
  end

  def full_range
    0..@splitted_hangul.length-1
  end

  def string(range = nil, k = 0)
    range = full_range unless range
    if k == 0
      res = @string[range]
    else
      res = @string[range][0...-1]
      ch = @splitted_hangul[range.last].dup
      ch[2] = ' '
      res += ch_join(ch)
    end

    return res.freeze
  end

  private

  Chosung_list = ["ㄱ","ㄲ","ㄴ","ㄷ","ㄸ","ㄹ","ㅁ","ㅂ","ㅃ","ㅅ",
       "ㅆ","ㅇ","ㅈ","ㅉ","ㅊ","ㅋ","ㅌ","ㅍ","ㅎ" ]
  Jungsung_list = ["ㅏ","ㅐ","ㅑ","ㅒ","ㅓ","ㅔ","ㅕ","ㅖ","ㅗ","ㅘ","ㅙ","ㅚ",
        "ㅛ","ㅜ","ㅝ","ㅞ","ㅟ","ㅠ","ㅡ","ㅢ","ㅣ"]
  Jongsung_list = [" ","ㄱ","ㄲ","ㄳ","ㄴ","ㄵ","ㄶ","ㄷ","ㄹ","ㄺ",
        "ㄻ","ㄼ","ㄽ","ㄾ","ㄿ","ㅀ","ㅁ","ㅂ","ㅄ","ㅅ",
        "ㅆ","ㅇ","ㅈ","ㅊ","ㅋ","ㅌ","ㅍ","ㅎ"]


  def unicode_of(a)
    a.unpack("U*").pop
  end

  def ch_split( ch )
    res = []
    offset = unicode_of("가")
    unicode = unicode_of( ch )
    res.push Chosung_list[ (unicode-offset) /
      (Jungsung_list.length * Jongsung_list.length) ]
    res.push Jungsung_list[((unicode-offset)%
        (Jungsung_list.length * Jongsung_list.length)) /
            Jongsung_list.length ]
    res.push Jongsung_list[ (unicode-offset) % Jongsung_list.length ]

    return res.freeze
  end

  def ch_join(sch)
    offset = unicode_of("가")
    offset += Chosung_list.index(sch[0]) * Jungsung_list.length * Jongsung_list.length
    offset += Jungsung_list.index(sch[1]) * Jongsung_list.length
    offset += Jongsung_list.index(sch[2])

    return [offset].pack("U*")
  end

  def hangul_split(string)
    string.split("").map do |ch|
      if /[가-힣]/ =~ ch
        ch_split(ch)
      else
        ch
      end
    end
  end

  def hangul_join(splitted_hangul)
  end


end