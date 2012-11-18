class Dword
  attr_accessor :word, :charStart, :charEnd, :sentIdx, :wordid, :ref, :coref
  
  def self.elementFactory(element, words)
    xmlText = element.get_text.to_s.lstrip.rstrip
    id = element.attributes["ID"]

    initCharStart = charStart(words)
    
    xmlText.split(/\s+/).each do |word|
      dword = Dword.new(word)
      dword.wordid = id

      dword.charStart = initCharStart
      dword.charEnd = dword.charStart + word.length - 1

      initCharStart = initCharStart + word.length

      words.push dword
    end
  end
  
  def self.textFactory(text, words)

    initCharStart = charStart(words)

    text.to_s.lstrip.rstrip.split(/\s+/).each do |word|
      dword = Dword.new(word)
      
      dword.charStart = initCharStart
      dword.charEnd = dword.charStart + word.length - 1

      initCharStart = initCharStart + word.length

      words.push dword
    end

  end

  def self.charStart(words)
    sent = ""

    words.each do |word|
      sent = "#{sent}#{word.word}"
    end

    sent.gsub(/\s+/, "").length
  end
  
  def initialize(word)
    @word = word
  end

  def charAtIndex(idx)
    currentIdx = idx - @charStart

    if @word.length > currentIdx
      @word.chars.to_a[currentIdx]
    else
      ""
    end
  end
  
  def to_s
    return_string = "#{@word}"
    if wordid != nil
      return_string = "#{return_string} wordid:#{@wordid}"
    end
    
    if sentIdx != nil
      return_string = "#{return_string} sentIdx:#{@sentIdx}"
    end
    
    if ref != nil
      return_string = "#{return_string} ref:#{@ref}"
    end
    return_string
  end
end