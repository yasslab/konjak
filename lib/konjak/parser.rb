require 'nokogiri'

module Konjak
  class Parser
    def parse(xml)
      doc = Nokogiri::XML.parse(xml) {|c| c.noblanks }
      Tmx.new doc.root
    end
  end
end
