module Konjak
  class Placeholder < InlineElement
    # optional attrs
    tmx_attr_accessor(:x)
    tmx_attr_accessor(:type)
    tmx_attr_accessor(:assoc)

    # methods
    def can_contain?(element)
      CodeData === element || SubFlow === element
    end
  end
end
