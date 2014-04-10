module Konjak
  class UserDefinedEncoding < StructuralElement
    # required attrs
    attr_accessor :name

    # FIXME
    #    base (required if one or more of the <map/> elements contains a code attribute).
    # optional attrs
    attr_accessor :base

    def can_contain?(element)
      Map === element
    end
  end
end
