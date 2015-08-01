module Konjak
  class Note < StructuralElement
    TAG_NAME = 'note'

    # optional attrs
    tmx_attr_accessor(:xml_lang,   :'xml:lang')
    tmx_attr_accessor(:o_encoding, :"o-encoding")

    # childrens
    def text
      super
    end

    # methods
    def can_contain?(element)
      String === element
    end
  end
end
