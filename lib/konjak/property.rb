module Konjak
  class Property < StructuralElement
    # required attrs
    attr_accessor :type

    # optional attrs
    attr_accessor :xml_lang, :o_encoding

    def can_contain?(element)
      # FIXME
      #    Tool-specific data or text.
      Text === element
    end

    def unpublished?
      type.start_with? 'x-'
    end
  end
end
