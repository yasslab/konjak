module Konjak
  class TranslationUnit < StructuralElement
    # optional attrs
    attr_accessor :tuid, :o_encoding, :data_type, :usage_count, :last_usage_date
    attr_accessor :creation_tool, :creation_tool_version, :creation_date
    attr_accessor :creation_id, :change_date, :seg_type, :change_id, :o_tmf
    attr_accessor :src_lang

    # children
    attr_accessor :variants

    def initialize(tu)
      # attrs
      @tuid            = tu[:tuid]
      @data_type       = tu[:datatype]
      @usage_count     = tu[:usagecount]
      @last_usage_date = tu[:lastusagedate]

      # children
      @variants = tu.children.select {|c| c.name == 'tuv' }.map {|tuv| TranslationUnitVariant.new tuv }
    end

    def can_contain?(element)
      [Note, Property, TranslationUnitVariant].any? {|c| c === element }
    end

    # Logically, a complete translation-memory database will contain at least two <tuv> elements in each translation unit.
    def complete?
      child_elements.count {|e| TranslationUnitVariant === e } >= 2
    end

    # FIXME
    #     Zero, one or more <note>, or <prop> elements in any order, followed by
    #     One or more <tuv> elements.
    def valid?
      child_elements.count {|e| TranslationUnitVariant === e } >= 1
    end
  end
end
