module Konjak
  class Note < StructuralElement
    # optional attrs
    attr_accessor :xml_lang, :o_encoding

    # text
    attr_accessor :text

    def initialize(note)
      super

      @xml_lang   = note["xml:lang"]
      @o_encoding = note["o-encoding"]
      @text       = Text.new(note.text)
    end

    def can_contain?(element)
      Text === element
    end
  end
end
