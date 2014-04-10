module Konjak
  class Body < StructuralElement
    def can_contain?(element)
      TranslationUnit === element
    end
  end
end
