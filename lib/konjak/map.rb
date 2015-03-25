module Konjak
  class Map < StructuralElement
    # required attrs
    attr_accessor :unicode

    # optional attrs
    attr_accessor :code, :entity, :substitution

    def initialize(map)
      # TODO
    end

    # FIXME:
    #     code, ent and subst. At least one of these attributes should be specified.
    #     If the code attribute is specified, the parent <ude> element must specify a base attribute.
    def can_contain?(element)
      false
    end
  end
end
