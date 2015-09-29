require 'konjak/segment/gtt'
require 'mem'

module Konjak
  # container
  class Segment < StructuralElement
    TAG_NAME = 'seg'
    WHITE_SPACE_PATTERN_TEXT = '\s'
    POSSESSIVE_QUALIFIER = '++'

    include GTT
    include Mem

    # children
    def text
      super
    end

    # methods
    def can_contain?(element)
      [String, BeginPairedTag, EndPairedTag, IsolatedTag, Placeholder, Highlight].any? {|c| c === element }
    end

    def compile_pattern
      regexp = Regexp.escape(text)
      regexp.gsub!(/(?<!^)\\\s/)     { WHITE_SPACE_PATTERN_TEXT }
      regexp.gsub!(/(?<!^)(?:\\s)+/) {|s| s + POSSESSIVE_QUALIFIER }
      Regexp.compile(regexp)
    end

    def translation_unit
      TranslationUnit.new(translation_unit_variant.parent)
    end

    def translation_unit_variant
      TranslationUnitVariant.new(parent)
    end
  end
end
