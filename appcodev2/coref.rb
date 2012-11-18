class Coref
	attr_accessor :words, :ref

	def initialize
		@words = []
	end

	def addword(word)
		@words.push(word)
	end

	def wordid
		if @words.length > 0
			@words[0].wordid
		else
			nil
		end
	end
end