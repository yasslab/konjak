module Konjak
  class UserDefinedEncoding < StructuralElement
    # required attrs
    tmx_attr_accessor(:name, required: true)

    # FIXME
    #    base (required if one or more of the <map/> elements contains a code attribute).
    # optional attrs
    tmx_attr_accessor(:base)

    # childrens
    def maps
      children.select {|c| c.name == 'map' }.map {|n| Map.new(n) }
    end

    # methods
    def can_contain?(element)
      Map === element
    end
  end
end
