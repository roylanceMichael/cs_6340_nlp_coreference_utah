require_relative './ncrf.rb'

if ARGV != nil && ARGV.length > 0
  content = (File.new ARGV[0]).read

  ncrf = Ncrf.new(content, nil, nil, nil)

  if(ARGV[1] != nil)
  	Ncrf.setVerbose(true)
  end

  ncrf.outputXml
end