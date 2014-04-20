module Konjak
  class Note < StructuralElement
    # optional attrs
    attr_accessor :xml_lang, :o_encoding

    def initialize(note)
    end

    def can_contain?(element)
      Text === element
    end
  end
end
