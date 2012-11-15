require './ncrf.rb'
#this will be called when initiated from the command line
if ARGV != nil && ARGV.length > 0
  #ARGV[0] is the location of the files for the factory
  Ncrf.factory ARGV[0], ARGV[1]
end