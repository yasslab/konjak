module Konjak
  class Tmx < StructuralElement
    # required attrs
    attr_accessor :version

    # FIXME
    #   One <header> followed by
    #   One <body> element.
    def can_contain?(element)
      Header === element || Body === element
    end
  end
end
