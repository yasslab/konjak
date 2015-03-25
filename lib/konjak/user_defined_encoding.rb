module Konjak
  class UserDefinedEncoding < StructuralElement
    # required attrs
    attr_accessor :name

    # FIXME
    #    base (required if one or more of the <map/> elements contains a code attribute).
    # optional attrs
    attr_accessor :base

    # children
    attr_accessor :maps

    def initialize(ude)
      @name = ude[:name]
      @base = ude[:base]
      @maps = ude.children.select {|c| c.name == 'map' }.map {|n| Map.new n }
    end

    def can_contain?(element)
      Map === element
    end
  end
end
