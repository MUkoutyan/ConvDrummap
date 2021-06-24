require "rexml/document"

puts "Input Path : #{ARGV[0]}"
doc = REXML::Document.new(open(ARGV[0]))

patchName = ""
doc.elements.each('DrumMap/string') do | elm |
    patchName = elm.attributes['value'] if elm.attributes['name'] == 'Name'
end

puts "Patch Name : #{patchName}"
pitchNames = {}

print "Fetch note-name hash"
doc.elements.each('DrumMap/list/item') do |element|

    noteAttr = element.elements.select do | i |
        i.attributes['name'] == 'INote'
    end
    note = noteAttr[0].attributes['value'] unless noteAttr.empty?

    element.elements.each('string') do | name |
        if note
            pitchNames[note] = name.attributes['value']
        end
    end
end

puts " : Complete."

outputFileName = "#{File.basename("#{ARGV[0]}", ".drm")}.pitchlist"
print "Write File : #{outputFileName}"

outputDoc = REXML::Document.new
outputDoc.context[:attribute_quote] = :quote
outputDoc << REXML::XMLDecl.new('1.0', 'UTF-8')

pitchNameList = REXML::Element.new('Music.PitchNameList')
outputDoc.add_element(pitchNameList)

pitchNameList.add_attribute("title", patchName)
pitchNames.each do | note, name |
    pitchName =  REXML::Element.new('Music.PitchNameList')
    pitchName.add_attribute("pitch", note)
    pitchName.add_attribute("name", name)
    pitchName.add_attribute("flags", "hide")
    pitchNameList.add_element(pitchName)
end


File.open(outputFileName, 'w') do |file|
    outputDoc.write(file, indent=4)
end
puts " : Complete."