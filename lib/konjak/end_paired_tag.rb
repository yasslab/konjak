module Konjak
  class EndPairedTag < InlineElement
    # required attrs
    tmx_attr_accessor(:i, required: true)

    # methods
    def can_contain?(element)
        CodeData === element ||  SubFlow === element
    end
  end
end
