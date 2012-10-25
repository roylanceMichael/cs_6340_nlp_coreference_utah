class ParseData
  
  #let's go down this route tomorrow... 10:00 time for relaxing...
  def onlyNP(content)
    nps = []
    if content == nil
      return nps
    end
    
    propRegex = /\(NP/
    
    match = propRegex.match content
    while match != nil
      i = 1
      #need to find everything it belongs to...
      tmp = ""
      npPhrase = ""
      c = match.post_match
      j = 0
      while i > 0 && j < c.length
        char = c[j]
        puts "#{char} - #{tmp} - #{npPhrase}"
        if char == ")"
          i = i - 1
          npPhrase = "#{npPhrase} #{tmp}"
          tmp = ""
        elsif char == "("
          i = i + 1
        elsif (char =~ /\s/) != nil
          tmp = ""
        else
          tmp = "#{tmp}#{char}"
        end
        j = j + 1
      end
      nps.push npPhrase.gsub(/\s+/, " ").lstrip.rstrip
      match = propRegex.match match.post_match
    end
    nps
  end
  
  def processParen(content, i)
    if content == nil || i >= content.length || content[i] != "("
      return ""
    end
    
    #increment
    i = i + 1
    key = ""
    #note: value can be string or object
    value = ""
    tmp = ""
    while i < content.length && content[i] != ")"
      char = content[i]
      if char == "("
        value = processParen(content, i)
        
        if value != nil && value[:int] != nil
          i = value[:int]
          value.delete :int
        end
        
      elsif (char =~ /\s/) != nil
        i = i + 1
        key = tmp
        tmp = ""
      else
        i = i + 1
      end
      tmp = "#{tmp}#{char}"
    end
    
    if value == nil || value == "" || value.class != Hash
      value = tmp
    end
    
    {key => value, :int => i}
  end
  
  def parseNounPhrases(content)
    #basically, we're going to start at the first 
    if content == nil
      return ""
    end
    
    idx = 0
    hash = {}
    tmp = ""
    key = ""
    value = ""
    for i in 0..content.length
      char = content[i]
      
      if char == "("
        idx = idx + 1
        if tmp != ""
          puts "found (! - #{idx} => #{tmp}"
          tmp = ""
        else
          puts "found (! - #{idx}"
        end
      elsif char == ")"
        idx = idx - 1
        value = tmp
        hash[key] = value
        puts "found !) - #{idx} => #{tmp}"
        tmp = ""
        if idx == 0
          return hash
        end
      elsif (char =~ /\s/) != nil && tmp != ""
        puts "found _ => #{tmp}"
        key = tmp
        tmp = ""
      else
        tmp = "#{tmp}#{char}"
      end
    end
    puts hash
    hash
  end
end