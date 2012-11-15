class Utilities
  def returnIdxInfo(sent, sub)
    sentArray = sent.split(/\s+/)
    subArray = sub.split(/\s+/)
    res = sentIdxInfo sentArray, subArray
    res
  end
  
  def self.cleanseRegexString(val)
    if val == nil
      return ""
    end
    return val.gsub(/[\[\]]/, "")
  end
  
  def self.editDistance(val1, val2)
    val1 = val1.downcase
    val2 = val2.downcase
    if(val1 == nil || val2 == nil)
      return 1
    end
    
    d = []
    for i in 0..val1.length
      d.push []
      for j in 0..val2.length
        d[i][j] = 999
      end
    end
    
    valChar1 = val1.chars.to_a
    valChar2 = val2.chars.to_a
    
    for i in 0..val1.length
      for j in 0..val2.length
        
        if(i == 0 && j == 0)
          d[i][j] = 0
        end
        
        if(j == 0)
          d[i][j] = i
        elsif(i == 0)
          d[i][j] = j
        else
          firstTemp = d[i-1][j] + 1
          secondTemp = d[i][j-1] + 1
          cost = valChar1[i-1] == valChar2[j-1] ? 0 : 2
          thirdTemp = d[i-1][j-1] + cost
          
          #puts "#{i} #{j} #{valChar1[i-1]} #{valChar2[j-1]} #{d[i][j]} -> firstTemp is #{firstTemp} - secondTemp is #{secondTemp} - thirdTemp is #{thirdTemp}"
          
          if(firstTemp <= secondTemp && firstTemp <= thirdTemp)
            d[i][j] = firstTemp
          elsif(secondTemp <= firstTemp && secondTemp <= thirdTemp)
            d[i][j] = secondTemp
          else
            d[i][j] = thirdTemp
          end
          #printArray(d, val1, val2)
        end
      end
    end
    
    d[val1.length][val2.length]
  end
  
  def self.printArray(d, val1, val2)
    for i in 0...val1.length
      str = ""
      for j in 0...val2.length
        str = "#{str} #{d[i][j]}"
      end
      puts str
    end
  end
  
  def sentIdxInfo(sentArray, subArray)
    # going to find the last occurrence...
    startIdx = nil
    endIdx = nil
    match = 0
    
    for i in 0...sentArray.length
      #puts "sent => #{sentArray[i]} : sub => #{subArray[match]}"
      
      if sentArray[i] == subArray[match]
        #puts "match found! #{i} #{match}"
        if startIdx == nil
          startIdx = i
        end
        
        endIdx = i
        
        match = match + 1
        
        if match == subArray.length
          break
        end
      else
        startIdx = nil
        endIdx = nil
        match = 0
      end
    end
    
    tmpHash = {:startIdx => startIdx, :endIdx => endIdx}
    tmpHash
  end
end