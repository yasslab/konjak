module Konjak
  class Note < StructuralElement
    # optional attrs
    tmx_attr_accessor(:xml_lang,   :'xml:lang')
    tmx_attr_accessor(:o_encoding, :"o-encoding")

    # childrens
    def text
      Text.new(super)
    end

    # methods
    def can_contain?(element)
      Text === element
    end
  end
end
