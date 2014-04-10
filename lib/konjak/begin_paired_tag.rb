module Konjak
  class BeginPairedTag < InlineElement
    # required attrs
    attr_accessor :i

    # optional attrs
    attr_accessor :x, :type

    def can_contain?(element)
      CodeData === element || SubFlow === element
    end
  end
end
