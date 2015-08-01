module Konjak
  class TranslationUnit < StructuralElement
    TAG_NAME = 'tu'

    # optional attrs
    tmx_attr_accessor(:tuid)
    tmx_attr_accessor(:o_encoding,            :"o-encoding")
    tmx_attr_accessor(:data_type,             :datatype)
    tmx_attr_accessor(:usage_count,           :usagecount)
    tmx_attr_accessor(:last_usage_date,       :lastusagedate)
    tmx_attr_accessor(:src_lang,              :srclang)
    tmx_attr_accessor(:creation_tool,         :creationtool)
    tmx_attr_accessor(:creation_tool_version, :creationtoolversion)
    tmx_attr_accessor(:creation_date,         :creationdate)
    tmx_attr_accessor(:creation_id,           :creationid)
    tmx_attr_accessor(:change_date,           :changedate)
    tmx_attr_accessor(:seg_type,              :segtype)
    tmx_attr_accessor(:change_id,             :changeid)
    tmx_attr_accessor(:o_tmf,                 :"o-tmf")
    tmx_attr_accessor(:src_lang,              :srclang)

    # childrens
    def variants
      children.select {|c| c.name == TranslationUnitVariant::TAG_NAME }.map {|tuv| TranslationUnitVariant.new(tuv) }
    end

    # methods
    def can_contain?(element)
      [Note, Property, TranslationUnitVariant].any? {|c| c === element }
    end

    # Logically, a complete translation-memory database will contain at least two <tuv> elements in each translation unit.
    def complete?
      variants.count >= 2
    end

    def has_translation?(src_lang, target_lang)
      src_lang?(src_lang) && has_variant_lang?(src_lang) && has_variant_lang?(target_lang)
    end

    def src_lang?(src_lang)
      !self.src_lang || self.src_lang == '*all*' || self.src_lang == src_lang
    end

    def has_variant_lang?(lang)
      variants.any? {|v| v.xml_lang == lang }
    end

    def variant(lang)
      variants.detect {|v| v.xml_lang == lang }
    end

    # FIXME
    #     Zero, one or more <note>, or <prop> elements in any order, followed by
    #     One or more <tuv> elements.
    def valid?
      variants.count >= 1
    end
  end
end
