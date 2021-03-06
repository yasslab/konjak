module Konjak
  class Property < StructuralElement
    TAG_NAME = 'prop'

    # required attrs
    tmx_attr_accessor(:type, required: true)

    # optional attrs
    tmx_attr_accessor(:xml_lang,   :'xml:lang')
    tmx_attr_accessor(:o_encoding, :"o-encoding")

    # childrens
    def text
      super
    end

    # methods
    def can_contain?(element)
      # FIXME
      #    Tool-specific data or text.
      String === element
    end

    def unpublished?
      type.start_with? 'x-'
    end
  end
end
