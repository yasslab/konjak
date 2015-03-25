module Konjak
  class TranslationUnitVariant < StructuralElement
    # required attrs
    attr_accessor :xml_lang

    # optional attrs
    attr_accessor :o_encoding, :data_type, :usage_count, :last_usage_date
    attr_accessor :creation_tool, :creation_tool_version, :creation_date
    attr_accessor :creation_id, :change_date, :change_id, :o_tmf

    def initialize(tuv)
      @xml_lang              = tuv['xml:lang']
      @o_encoding            = tuv['o-encoding']
      @data_type             = tuv['datatype']
      @usage_count           = tuv['usagecount']
      @last_usage_date       = tuv['lastusagedate']
      @creation_tool         = tuv['creationtool']
      @creation_tool_version = tuv['creationtoolversion']
      @creation_date         = tuv['creationdate']
      @creation_id           = tuv['creationid']
      @change_date           = tuv['changedate']
      @change_id             = tuv['changeid']
      @o_tmf                 = tuv['o-tmf']
    end

    # FIXME
    #     Zero, one or more <note>, or <prop> elements in any order, followed by
    #     One <seg> element.
    def can_contain?(element)
      [Note, Property, Segment].any? {|c| c === element }
    end
  end
end
