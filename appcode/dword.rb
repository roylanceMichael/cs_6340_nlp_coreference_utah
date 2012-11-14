class Dword
  attr_accessor :word, :sentIdx, :id, :ref
  
  def self.elementFactory(element)
    xmlText = element.get_text.to_s.lstrip.rstrip
    id = element.attributes["ID"]
    words = []
    
    xmlText.split(/\s+/).each do |word|
      dword = Dword.new(word)
      dword.id = id
      words.push dword
    end
    
    words
  end
  
  def self.textFactory(text)
    words = []
    
    text.to_s.lstrip.rstrip.split(/\s+/).each do |word|
      dword = Dword.new(word)
      words.push dword
    end
    
    words
  end
  
  def initialize(word)
    @word = word
  end
  
  def to_s
    return_string = "#{word}"
    if id != nil
      return_string = "#{return_string} id:#{id}"
    end
    
    if sentIdx != nil
      return_string = "#{return_string} sentIdx:#{sentIdx}"
    end
    
    if ref != nil
      return_string = "#{return_string} ref:#{ref}"
    end
    return_string
  end
end