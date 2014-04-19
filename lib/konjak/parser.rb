require 'nokogiri'

module Konjak
  class Parser
    def parse(xml)
      Tmx.new Nokogiri.parse(xml).root
    end
  end
end
