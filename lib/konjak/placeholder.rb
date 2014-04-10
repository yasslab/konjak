module Konjak
  class Placeholder < InlineElement
    # optional attrs
    attr_accessor :x, :type, :assoc

    def can_contain?(element)
      CodeData === element || SubFlow === element
    end
  end
end
