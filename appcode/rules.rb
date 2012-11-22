class Rules

	#this will determine if the np's match in number
	def matchPlurality(npModel1, npModel2)
	    if(npModel1.plurality == npModel2.plurality)
		return true
	    else
		return false
	    end
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
		prevSentences = []
	
		for i in 0...sentIdx
		  prevSentences.push sentences[i]
		end
	
		#starting at the beginning, find the first np with any sort of match to our current phrase
		npPhrase = npModel.phrase.split(/\s+/)
		regexs = []
		npPhrase.each do |word|
		  regexs.push word
		end
	
		match = false
	
		prevSentences.each do |prevSent|
	  
		  prevSent.npModels.each do |acceptableNp|
		
			regexs.each do |regex|
		  
			  acceptableNp.phrase.split(/\s+/).each do |word|
			
				if Utilities.editDistance(regex, word) <= 1
					puts "matching #{acceptableNp.phrase} <- #{npModel.phrase}"
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
		mismatchCount.to_f / largerSize.to_f
	end

	def self.headnounsDiffer(npModel1, npModel2)
		if npModel1.headNoun != npModel2.headNoun
			1
		else
			0
		end
	end

 def self.findCorrectAnt(npModel, sentIdx, sentences)
	#right now, just going to find the first np in the preceding sentence
	
	#adding in a check for plurality here, hopefully this
	#gives us some improvement
	if sentIdx > 0
	  preSentIdx = sentIdx - 1
	  preSent = sentences[preSentIdx]
	  
	  #do I exist in my npModels right now?
	  
	  stanfordNps = preSent.npModels.select{ |t|
	     t.coref == false
	  }
	  otherNps = preSent.npModels.select{ |t|
	      t.coref == true
	  }
	  if stanfordNps.length > 0 and matchPlurality(npModel, stnafordNps[0])
		foundNp = stanfordNps[0]
		foundNp.included = true
		npModel.ref = foundNp
	  elsif otherNps.length > 0 and matchPlurality(npModel, otherNps[0])
		foundNp = otherNps[0]
		foundNp.included = true
		npModel.ref = foundNp
	  end
	end
  end
end
