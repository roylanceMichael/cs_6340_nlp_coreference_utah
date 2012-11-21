class IncompatFun
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
					return 1
				end
			end
		end
		return 0
	end


end