class SentenceModel
	attr_accessor :words

	def initialize
		@words = []
	end

	def addWord(word)
		@words.push word
	end

	def corefs
		foundCorefs = []

		@words.select{|t| t.coref != nil}.each do |coref|
			if !(foundCorefs.include? coref.coref)
				foundCorefs.push coref.coref
			end
		end

		foundCorefs
	end

	def sentIdx
		if @words.length > 0
			@words[0].sentIdx
		else
			nil
		end
	end

	def printxml
		#if a word is not a coref, then we will print it by itself

		
	end
end