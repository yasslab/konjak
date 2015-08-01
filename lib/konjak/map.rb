module Konjak
  class Map < StructuralElement
    TAG_NAME = 'map'

    # required attrs
    tmx_attr_accessor(:unicode, required: true)

    # optional attrs
    tmx_attr_accessor(:code)
    tmx_attr_accessor(:entity,       :ent)
    tmx_attr_accessor(:substitution, :subst)

    # methods

    # FIXME:
    #     code, ent and subst. At least one of these attributes should be specified.
    #     If the code attribute is specified, the parent <ude> element must specify a base attribute.
    def can_contain?(element)
      false
    end
  end
end
