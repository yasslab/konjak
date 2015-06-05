module Konjak
  # DEPRECATED
  class UnknownTag < InlineElement
    # optional attrs
    tmx_attr_accessor(:x)

    # methods
    def can_contain?(element)
      CodeData === element || SubFlow === element
    end
  end
end
