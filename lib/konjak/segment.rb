require 'konjak/segment/gtt'

module Konjak
  # container
  class Segment < StructuralElement
    include GTT

    # children
    def text
      Text.new(super)
    end

    # methods
    def can_contain?(element)
      [Text, BeginPairedTag, EndPairedTag, IsolatedTag, Placeholder, Highlight].any? {|c| c === element }
    end

    def translation_unit
      TranslationUnit.new(translation_unit_variant.parent)
    end

    def translation_unit_variant
      TranslationUnitVariant.new(parent)
    end
  end
end
