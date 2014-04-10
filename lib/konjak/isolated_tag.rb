module Konjak
  class IsolatedTag < InlineElement
    # required attrs
    attr_accessor :pos

    # optional attrs
    attr_accessor :x, :type

    def can_contain?(element)
      CodeData === element || SubFlow === element
    end
  end
end
