module Konjak
  class Body < StructuralElement
    # childrens
    def translation_units
      children.select {|c| c.name == 'tu' }.map {|tu| TranslationUnit.new(tu) }
    end

    # methods
    def can_contain?(element)
      TranslationUnit === element
    end
  end
end
