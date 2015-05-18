require 'nokogiri'

module Konjak
  class Parser
    def parse(xml, gtt: false)
      if gtt
        # FIXME
        xml = xml.gsub(/&amp;(#\d+|#x[0-9a-fA-F]+|[0-9a-zA-Z]+);/) { "&#{$1};" }
      end
      doc = Nokogiri::XML.parse(xml) {|c| c.noblanks }
      Tmx.new doc.root
    end
  end
end
