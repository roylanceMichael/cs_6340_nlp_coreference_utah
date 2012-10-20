require 'rexml/document'

class Crf
  attr_accessor :rawXml

  def initialize(content)
    @rawXml = REXML::Document.new(content)    
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