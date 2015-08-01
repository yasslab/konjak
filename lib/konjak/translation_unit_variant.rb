module Konjak
  class TranslationUnitVariant < StructuralElement
    TAG_NAME = 'tuv'

    # required attrs
    tmx_attr_accessor(:xml_lang, :'xml:lang', required: true)

    # optional attrs
    tmx_attr_accessor(:o_encoding,            :"o-encoding")
    tmx_attr_accessor(:data_type,             :datatype)
    tmx_attr_accessor(:usage_count,           :usagecount)
    tmx_attr_accessor(:last_usage_date,       :lastusagedate)
    tmx_attr_accessor(:creation_tool,         :creationtool)
    tmx_attr_accessor(:creation_tool_version, :creationtoolversion)
    tmx_attr_accessor(:creation_date,         :creationdate)
    tmx_attr_accessor(:creation_id,           :creationid)
    tmx_attr_accessor(:change_date,           :changedate)
    tmx_attr_accessor(:change_id,             :changeid)
    tmx_attr_accessor(:o_tmf,                 :"o-tmf")

    # childrens
    def notes
      children.select {|c| c.name == 'note' }.map {|n| Note.new(n) }
    end

    def properties
      children.select {|c| c.name == 'prop' }.map {|n| Property.new(n) }
    end

    def segment
      Segment.new(children.detect {|c| c.name == Segment::TAG_NAME })
    end

    # methods

    # FIXME
    #     Zero, one or more <note>, or <prop> elements in any order, followed by
    #     One <seg> element.
    def can_contain?(element)
      [Note, Property, Segment].any? {|c| c === element }
    end
  end
end
