require './ncrf.rb'
#this will be called when initiated from the command line
if ARGV != nil && ARGV.length > 0
  #ARGV[0] is the location of the files for the factory
  puts ARGV[2]
  if ARGV[2] != nil
  	Ncrf.factory ARGV[0], ARGV[1], true
  else
  	Ncrf.factory ARGV[0], ARGV[1], false
  end
end