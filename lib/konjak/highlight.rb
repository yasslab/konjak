module Konjak
  class Hilight < InlineElement
    # optional attrs
    tmx_attr_accessor(:x)
    tmx_attr_accessor(:type)

    # methods

    # FIXME
    #     Text data,
    #     Zero, one or more of the following elements: <bpt>, <ept>, <it>, <ph>, and <hi>.
    #     They can be in any order, except that each <bpt> element must have a subsequent corresponding <ept> element.
    def can_contain?(element)
      [String, BeginPairedTag, EndPairedTag, IsolatedTag, Placeholder, Hilight].any? {|c| c === element }
    end
  end
end
