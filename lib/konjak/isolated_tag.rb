module Konjak
  class IsolatedTag < InlineElement
    # required attrs
    tmx_attr_accessor(:pos, required: true)

    # optional attrs
    tmx_attr_accessor(:x)
    tmx_attr_accessor(:type)

    # methods
    def can_contain?(element)
      CodeData === element || SubFlow === element
    end
  end
end
