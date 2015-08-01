module Konjak
  class Body < StructuralElement
    TAG_NAME = 'body'

    # childrens
    def translation_units
      children.select {|c| c.name == TranslationUnit::TAG_NAME }.map {|tu| TranslationUnit.new(tu) }
    end

    # methods
    def can_contain?(element)
      TranslationUnit === element
    end
  end
end
