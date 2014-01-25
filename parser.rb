require 'json'
require 'pp'
require 'memoize'
require 'yaml'

module Hangul
	Chosung_list = ["ㄱ","ㄲ","ㄴ","ㄷ","ㄸ","ㄹ","ㅁ","ㅂ","ㅃ","ㅅ",
			 "ㅆ","ㅇ","ㅈ","ㅉ","ㅊ","ㅋ","ㅌ","ㅍ","ㅎ" ]
	Jungsung_list = ["ㅏ","ㅐ","ㅑ","ㅒ","ㅓ","ㅔ","ㅕ","ㅖ","ㅗ","ㅘ","ㅙ","ㅚ",
			  "ㅛ","ㅜ","ㅝ","ㅞ","ㅟ","ㅠ","ㅡ","ㅢ","ㅣ"]
	Jongsung_list = [" ","ㄱ","ㄲ","ㄳ","ㄴ","ㄵ","ㄶ","ㄷ","ㄹ","ㄺ",
			  "ㄻ","ㄼ","ㄽ","ㄾ","ㄿ","ㅀ","ㅁ","ㅂ","ㅄ","ㅅ",
			  "ㅆ","ㅇ","ㅈ","ㅊ","ㅋ","ㅌ","ㅍ","ㅎ"]
	Vortaro = {
		"먹으"=> [:verbo],
		"달리"=> [:verbo],
		"을"=> [:josa],
		"를"=> [:josa],
		"은"=> [:josa],
		"는"=> [:josa]
	}

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

	  return res
	end

	def ch_join(sch) 
	  offset = unicode_of("가")
	  offset += Chosung_list.index(sch[0]) * Jungsung_list.length * Jongsung_list.length
	  offset += Jungsung_list.index(sch[1]) * Jongsung_list.length
	  offset += Jongsung_list.index(sch[2])

	  return [offset].pack("U*")
	end

	def hangul_split(hangul)
	  hangul.split("").map do |ch|
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

include Hangul


include Memoize

class HangulParser
	def initialize hangul
		@hangul = hangul
		memoize :frazo
		memoize :substantivo
		memoize :verbo
	end

	def splitted_hangul
		@splitted_hangul ||= hangul_split(@hangul)
	end

	def rompita_vortaro
		@rompita_vortaro ||= begin v = {}; Vortaro.map do |key, val| v[hangul_split(key)] = val end; v end
	end

	def bipartite r, k=0
		if k 
			hangul = splitted_hangul.clone
			hangul[r.last] = hangul[r.last].clone
			hangul[r.last][2] = " "
		else
			hangul = splitted_hangul
		end

		ri = r.begin + hangul[r].rindex(" ")
		return r.begin..ri-1, ri+1..r.last
	end

	def frazo r
		candidates = [[999999, nil]]
		splitted_hangul[r].reverse_each do |ch|
			if ch == "."
				candidates.push [
					1 + substantivo(r.first..r.last-1)[0],
					[substantivo(r.first..r.last-1)[1], "."]
				]
			end
		end

		puts JSON.pretty_generate ['frazo', r, candidates.min]

		return candidates.min
	end

	def substantivo r
		candidates = [[999999, nil]]
		if splitted_hangul[r.last][2] == "ㅁ"
			candidates.push [
				1 + verbo(r.first..r.last, 1)[0],
				[verbo(r.first..r.last, 1)[1], "ㅁ"]
			]
		end
		puts JSON.pretty_generate ['substantivo', r, candidates.min]
		return candidates.min
	end

	def verbo r, k
		hangul = splitted_hangul.clone
		hangul[r.last] = hangul[r.last].clone
		hangul[r.last][2] = " " if k

		candidates = [[999999, nil]]

		(left, right) = bipartite(r, k)

		if vorto = rompita_vortaro[hangul[right]] and vorto.include? :verbo
			left.reverse_each do |i|
				josa(i..left.last)
				c = [
					
				]
			end
			c = [
				1, hangul[right]
			]
			candidates.push c
		end
		
		puts JSON.pretty_generate ['verbo', r, candidates.min]
		return candidates.min
	end

	def josa r
		candidates = [[999999, nil]]
		if vorto = rompita_vortaro[splitted_hangul[r.last]] and vorto.include? :josa
			candidates.push [
				1 + substantivo(r.first..r.last-1)[0],
				substantivo(r.first..r.last-1)[1],
				vorto
			]
		end
	end
end

hp = HangulParser.new "나는 미역국을 먹음."

res = hp.frazo(0..hp.splitted_hangul.length-1)
#puts res.to_yaml

#puts hp.splitted_hangul.to_yaml

