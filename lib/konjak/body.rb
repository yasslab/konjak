module Konjak
  class Body < StructuralElement
    # children
    attr_accessor :translation_units

    def initialize(body)
      @translation_units = body.children.select {|c| c.name == 'tu' }.map {|tu| TranslationUnit.new tu }
    end

    def can_contain?(element)
      TranslationUnit === element
    end
  end
end
