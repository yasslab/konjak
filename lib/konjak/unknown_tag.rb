module Konjak
  # DEPRECATED
  class UnknownTag < InlineElement
    # optional attrs
    attr_accessor :x

    def can_contain?(element)
      CodeData === element || SubFlow === element
    end
  end
end
