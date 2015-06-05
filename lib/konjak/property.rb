module Konjak
  class Property < StructuralElement
    # required attrs
    attr_accessor :type

    # optional attrs
    attr_accessor :xml_lang, :o_encoding

    # child
    attr_accessor :text

    def initialize(property)
      super

      @type       = property[:type]
      @xml_lang   = property['xml:lang']
      @o_encoding = property['o-encoding']
      @text       = Text.new(property.text)
    end

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
