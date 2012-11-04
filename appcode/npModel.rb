# poro for handling info... i like strongly typed for this stuff
class NpModel
  #ref is a reference to another NpModel...
  attr_accessor :id, :startIdx, :endIdx, :sentIdx, :phrase, :sent, :ref, :included,
                :coref, :position, :pronounType, :article, :appositive, 
                :plurality, :properName, :semanticClass, :gender, :animacy, :headNoun
  
  #sent model, 
  def initialize(id, startIdx, endIdx, phrase, sent)
    @id = id
    @startIdx = startIdx
    @endIdx = endIdx
    @phrase = phrase
    @sent = sent
    identifyPlurality
  end
  
  def identifyPlurality
    words = @phrase.split(/\s+/)
    idx = words.length
    wordLength = words[idx-1].length
    if words[idx-1][wordLength-1] == 's'
      @plurality = true
    else
      @plurality = false
    end
  end
  
  
end