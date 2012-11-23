#this script scrapes a website for the 300 most common male and 
#female names and puts them in a text file for later use. males
#are put in male_names.txt and females are put in female_names.txt

#update: female names weren't laid out the same on the site so i'm
#putting getting female names on the back burner for now cause i
#cant scrap them easily
require 'rubygems'
require 'nokogiri'
require 'open-uri'

url = "http://names.mongabay.com/male_names.htm"
doc = Nokogiri::HTML(open(url))
match_url ="http://names.mongabay.com/baby-names/application/rank-M-US-"
regex = /^#{match_url}/
arr = doc.css("a").to_a
count = 0

male_file_builder = []
arr.each do |link|
    if(regex.match(link["href"].to_s) != nil)
	 male_file_builder << link.text + "\n"
    end	
end

File.open("male_names.txt", "w") { |f|
   file_builder.each do |name| 
    f.write name
   end
}
