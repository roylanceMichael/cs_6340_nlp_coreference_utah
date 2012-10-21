require 'rexml/document'

class Crf
  attr_accessor :rawXml

  def initialize(content)
    @rawXml = REXML::Document.new(content)    
  end
  
  def allWords
    words = []
    #only grab first node
    if @rawXml != nil && @rawXml.length > 0
      rootXml = @rawXml[0]
      rootXml.each do |element|
        if element.class == REXML::Element
          element.get_text.to_s.split(/\s+/).each do |word|
            words.push word
          end
        elsif element.class == REXML::Text
          element.to_s.split(/\s+/).each do |word|
            words.push word
          end
        end
      end
    end
    words
  end
  
  def corefs
    ret = []
    if @rawXml != nil && @rawXml.length > 0
      rootXml = @rawXml[0]
      rootXml.each do |element|
        if element.class == REXML::Element
          ret.push element
        end
      end
    end
    ret
  end
end