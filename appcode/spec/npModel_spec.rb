require 'spec_helper.rb'

describe NpModel do
	#basic poro tests
	describe "#ctor" do
		it "can add a word" do
			s1 = Sentence.new
			s2 = Sentence.new

			#sentence: She walked her dog to the store. <COREF ID='1'>It</COREF> was hungry.
			sent1 = ["She", "walked", "her", "dog", "to", "the", "store."]
			coref = REXML::Element.new("COREF")
			coref.add_attribute "ID", "1"
			coref.add_text "It"
			sent2 = ["was", "hungry"]

			sent1.each do |word|
				s1.addWord word
			end

			s2.elementAdd coref

			sent2.each do |word|
				s2.addWord word
			end

			s1.npAdd "She", "X1"
			s1.npAdd "her dog", "X2"
			s1.npAdd "the store.", "X3"

			s1.npModels[0].phrase.should eq("She")
			s1.npModels[1].phrase.should eq("her dog")
			s1.npModels[2].phrase.should eq("the store.")
			s2.npModels[0].phrase.should eq("It")
		end
	end

	describe "#comparing function" do
		it "can add a word" do
			s1 = Sentence.new
			s2 = Sentence.new

			#sentence: She walked her dog to the store. <COREF ID='1'>It</COREF> was hungry.
			sent1 = ["She", "walked", "her", "dog", "to", "the", "store."]
			coref = REXML::Element.new("COREF")
			coref.add_attribute "ID", "1"
			coref.add_text "It"
			sent2 = ["was", "hungry"]

			sent1.each do |word|
				s1.addWord word
			end

			s2.elementAdd coref

			sent2.each do |word|
				s2.addWord word
			end

			s1.npAdd "She", "X1"
			s1.npAdd "her dog", "X2"
			s1.npAdd "the store.", "X3"

			allSentences = [s1, s2]

			s2.npModel[0].findBestMatch allSentences
		end
	end
end