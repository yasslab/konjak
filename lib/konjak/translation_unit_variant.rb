module Konjak
  class TranslationUnitVariant < StructuralElement
    # required attrs
    attr_accessor :xml_lang

    # optional attrs
    attr_accessor :o_encoding, :data_type, :usage_count, :last_usage_date
    attr_accessor :creation_tool, :creation_tool_version, :creation_date
    attr_accessor :creation_id, :change_date, :change_id, :o_tmf

    # FIXME
    #     Zero, one or more <note>, or <prop> elements in any order, followed by
    #     One <seg> element.
    def can_contain?(element)
      [Note, Property, Segment].any? {|c| c === element }
    end
  end
end
