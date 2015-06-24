require 'nokogiri'

module Konjak
  class Parser
    attr_accessor :gtt

    def initialize(gtt: false)
      @gtt = gtt
    end

    def parse(xml)
      if gtt
        # FIXME GTT's tmx store &copy; as &amp;copy;
        xml = xml.gsub(/&amp;(#\d+|#x[0-9a-fA-F]+|[0-9a-zA-Z]+);/) { "&#{$1};" }
        # FIXME GTT's tmx store leading space(\u0020) as non-breaking space(\u00A0)
        xml = xml.gsub("\u00A0", ' ')
      end
      doc = Nokogiri::XML.parse(xml)
      Tmx.new doc
    end
  end
end
