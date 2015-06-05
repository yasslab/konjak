require 'nokogiri'

module Konjak
  class Parser
    attr_accessor :gtt

    def initialize(gtt: false)
      @gtt = gtt
    end

    def parse(xml)
      if gtt
        # FIXME
        xml = xml.gsub(/&amp;(#\d+|#x[0-9a-fA-F]+|[0-9a-zA-Z]+);/) { "&#{$1};" }
      end
      doc = Nokogiri::XML.parse(xml)
      Tmx.new doc
    end
  end
end
