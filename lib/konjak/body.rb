module Konjak
  class Body < StructuralElement
    def initialize(body)
    end

    def can_contain?(element)
      TranslationUnit === element
    end
  end
end
