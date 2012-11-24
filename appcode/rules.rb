class Rules

	#this will determine if the np's match in number
	def self.matchPlurality(npModel1, npModel2)
	    if(npModel1.plurality == npModel2.plurality)
		return true
	    else
		return false
	    end
	end

	def self.matchGender(npModel1, npModel2)
	    if(npModel1.gender != "UNKNOWN" &&
	       npModel2.gender != "UNKNOWN")
		if(npModel1.gender != npModel2.gender)
		    return false
		else
		    return true
		end
	    end
	end

	def self.articleRule(npModel)
	   if(!(npModel.appositive))
	     if(npModel.article == "a" || npModel.article == "an" || npModel.article == "some")
		return 0	
	     end
	   end 
		return 1	
	end

	def self.appositiveRule(npModel, sentences)
		#if this is true, then we want to set it to the previous npModel
		if npModel.appositive == true && npModel.sent != nil
			idx = 0

			npModel.sent.npModels.each do |npm|
				if npModel.id == npm.id
					break
				else
					idx = idx + 1
				end
			end

			if idx > 0
				ref = npModel.sent.npModels[idx-1]
				ref.included = true
				npModel.ref = ref
				true
			end
		end
		false
	end

	def self.wordsSubstring(npModel, sentIdx, sentences)
		if npModel.pronounType != "none"
			return
		end

		prevSentences = []
	
		for i in 0...sentIdx
		  prevSentences.push sentences[i]
		end
	
		#starting at the beginning, find the first np with any sort of match to our current phrase
		badWords = ["a", "an", "the", "of", "these"]
		npPhrase = npModel.phrase.split(/\s+/)
		regexs = []
		npPhrase.select{|t| !badWords.include?(t)}.each do |word|
		  regexs.push word
		end
	
		match = false

		prevSentences.reverse!
	
		prevSentences.each do |prevSent|
	  
		  prevSent.npModels.select{|t| t.pronounType == 'none'}.each do |acceptableNp|
		
			regexs.each do |regex|
		  
			  acceptableNp.phrase.split(/\s+/).select{|t| !badWords.include?(t)}.each do |word|
			
				if Utilities.editDistance(regex, word) <= 1
				  puts "matching <#{acceptableNp.phrase}> <- <#{npModel.phrase}>"
				  #this acceptableNp is a match
				  acceptableNp.included = true
				  npModel.ref = acceptableNp

				  return true
				end
			  end
			end
	 	 end
		end
	
		false
	end

	#1 Incompatibility function: 1 if both are proper names, but mismatch on every word; else 0
	def self.properNames(npModel1, npModel2)
		if npModel1 != nil && npModel2 != nil
			if npModel1.properName && npModel2.properName
				compat = false

				np1Words = npModel1.phrase.split(/\s+/)
				np2Words = npModel2.phrase.split(/\s+/)
				
				np1Words.each do |word1|
					
					np2Words.each do |word2|
						if word1 == word2
							compat = true
						end

						if compat
							break
						end
					end

					if compat
						break
					end
				end

				if !compat
					return true
				end
			end
		end
		return false
	end

	def self.pronounTypes(npModel1, npModel2)
		if npModel1.pronounType != "none" && npModel2.pronounType == "none"
			0
		else
			1
		end
	end

	def self.mismatchWords(npModel1, npModel2)
		firstWords = npModel1.phrase.split(/\s+/)
		secondWords = npModel2.phrase.split(/\s+/)

		#going to go with the larger one, cycle through it
		largerCollection = firstWords.length < secondWords.length ? secondWords : firstWords
		smallerCollection = firstWords.length < secondWords.length ? firstWords : secondWords

		largerSize = largerCollection.length
		smallerSize = smallerCollection.length

		mismatchCount = 0
		
		for i in 0...largerSize
			if i < smallerSize
				
				if largerCollection[i] != smallerCollection[i] && 
					npModel1.pronounType == "none" && 
					npModel2.pronounType == "none"
					mismatchCount = mismatchCount + 1
				end
			else
				mismatchCount = mismatchCount + 1
			end
		end
		(mismatchCount.to_f) / (largerSize.to_f)
	end

	def self.headnounsDiffer(npModel1, npModel2)
		if npModel1.headNoun != npModel2.headNoun
			1
		else
			0
		end
	end

	def self.subsume(npModel1, npModel2)
		if npModel1.phrase.length <= 1 || npModel2.phrase.length <= 1
			return 0
		end

		if npModel1.pronounType != "none"
			return 0
		end

		badWords = ["a", "an", "the", "of"]
		if badWords.include?(npModel2.phrase.downcase) || badWords.include?(npModel1.phrase.downcase)
			return 0
		end

		res = npModel1.phrase.index npModel2.phrase
		res != nil ? -9999 : 0
	end

	def self.imerule(npModel1, npModel2)
		norm1 = npModel1.phrase.downcase.lstrip.rstrip
		norm2 = npModel2.phrase.downcase.lstrip.rstrip

		if norm1 == "me" && norm2 == "i"
			#puts "IMERULE -> <#{norm1}> <#{norm2}>"
			return -9999
		end

		if norm1 == "i" && norm2 == "me"
			#puts "IMERULE -> <#{norm1}> <#{norm2}>"
			return -9999
		end

		return 0
	end

 def self.findCorrectAnt(npModel, sentIdx, sentences)
	#right now, just going to find the first np in the preceding sentence

	#ya, there's probably a more efficient way to get this. later...
	allNps = []
	sentences.each do |sent|
		sent.npModels.each do |np|
			allNps.push np
		end
	end

	lastNp = allNps.sort{|a, b| b.position <=> a.position}.first
	maxDistance = lastNp.position

	prevNps = []
	#puts "getting prev nps for sendIdx #{sentIdx} - #{npModel.phrase}"
	
	#get the preceding ones
	sentences.select{|t| t.sentIdx < sentIdx}.each do |sentence|
		sentence.npModels.each do |np|
			prevNps.push np
		end
	end

	#get the preceding ones from the current sentence
	npModel.sent.npModels.select{|t| t.startIdx < npModel.startIdx }.each do |prevNp|
		prevNps.push prevNp
	end

	prevNps.sort!{|a,b| b.position <=> a.position }

	#going to use a has to represent the result... { npModel, value }

	results = []

	puts "comparing #{npModel} with:"

	prevNps.each do |prevNp|
		score = 0
		subsumeScore = subsume(npModel, prevNp)
		reverseSubsumeScore = subsume(prevNp, npModel)

		#we don't need to compare anymore if this is true
		#mismatch words score
		score1 = mismatchWords(npModel, prevNp) * 10
		#head noun differ score
		score2 = headnounsDiffer(npModel, prevNp)
		#difference in position score
		score3 = (npModel.position - prevNp.position).abs.to_f / maxDistance.to_f * 5
		#pronoun score
		score4 = pronounTypes(npModel, prevNp)
		#plurality score
		#shouldn't this be ? 0 : 999? or maybe i don't understand ruby's ternary op's-ben
		#oh i see, your doing a change from greatest to least weighted np matching
		score5 = matchPlurality(npModel, prevNp) == true ? 999 : 0
		#proper names score
		score6 = properNames(npModel, prevNp) == true ? 999 : 0
		#gender score
		score7 = matchGender(npModel, prevNp) == true ? 999 : 0
		#article score	
		score8 = articleRule(prevNp)

		totalScore = score1 + score2 + score3 + score4 + score5 + score6 + score7 + score8

		totalScore = score1 + score2 + score3 + score4 + score5 + score6
		totalScore = totalScore + subsumeScore
		totalScore = totalScore + reverseSubsumeScore
		totalScore = totalScore + imerule(npModel, prevNp)

		tmpKvp = {:np => prevNp, :score => totalScore }
		results.push tmpKvp
		puts "totalScore: #{totalScore} #{prevNp}"
	end

	foundNp = results.sort{|a, b| a[:score] <=> b[:score] }.first

	if foundNp != nil
		
		puts "assigning <#{foundNp[:np].phrase} #{foundNp[:np].id}> to <#{npModel.phrase} #{npModel.id}> with score of #{foundNp[:score]}"
		puts ""

		foundNp[:np].included = true
		npModel.ref = foundNp[:np]
	end
  end
end
