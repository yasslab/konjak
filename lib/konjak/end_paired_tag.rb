module Konjak
  class EndPairedTag < InlineElement
    # required attrs
    attr_accessor :i

    def can_contain?(element)
        CodeData === element ||  SubFlow === element
    end
  end
end
