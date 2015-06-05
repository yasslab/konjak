module Konjak
  class BeginPairedTag < InlineElement
    # required attrs
    tmx_attr_accessor(:i, required: true)

    # optional attrs
    tmx_attr_accessor(:x)
    tmx_attr_accessor(:type)

    # methods
    def can_contain?(element)
      CodeData === element || SubFlow === element
    end
  end
end
