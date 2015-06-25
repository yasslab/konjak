require 'konjak/segment/gtt'
require 'mem'

module Konjak
  # container
  class Segment < StructuralElement
    include GTT
    include Mem

    # children
    def text
      Text.new(super)
    end

    # methods
    def can_contain?(element)
      [Text, BeginPairedTag, EndPairedTag, IsolatedTag, Placeholder, Highlight].any? {|c| c === element }
    end

    def compile_pattern
      regexp = Regexp.escape(text)
      regexp.gsub!(/(?<!^)\\\s/)          { '\s' }
      regexp.gsub!(/(?<!^)(?:\\s)+(?!$)/) {|s| s + '++' }
      Regexp.compile(regexp)
    end
    memoize :compile_pattern

    def translation_unit
      TranslationUnit.new(translation_unit_variant.parent)
    end

    def translation_unit_variant
      TranslationUnitVariant.new(parent)
    end
  end
end
