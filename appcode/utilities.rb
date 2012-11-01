class Utilities
  def returnIdxInfo(sent, sub)
    sentArray = sent.split(/\s+/)
    subArray = sub.split(/\s+/)
    
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