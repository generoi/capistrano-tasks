Dir.glob(File.dirname(__FILE__) + '../tasks/*.rake').each do |file|
  load file
end
