module Konjak
  class Header < StructuralElement
    TAG_NAME = 'header'

    # required attrs
    tmx_attr_accessor(:creation_tool,         :creationtool,        required: true)
    tmx_attr_accessor(:creation_tool_version, :creationtoolversion, required: true)
    tmx_attr_accessor(:seg_type,              :segtype,             required: true)
    tmx_attr_accessor(:o_tmf,                 :"o-tmf",             required: true)
    tmx_attr_accessor(:admin_lang,            :adminlang,           required: true)
    tmx_attr_accessor(:src_lang,              :srclang,             required: true)
    tmx_attr_accessor(:data_type,             :datatype,            required: true)

    # optional attrs
    tmx_attr_accessor(:o_encoding,    :"o-encoding")
    tmx_attr_accessor(:creation_date, :creationdate)
    tmx_attr_accessor(:creation_id,   :creationid)
    tmx_attr_accessor(:change_date,   :changedate)
    tmx_attr_accessor(:change_id,     :changeid)

    # childrens
    def notes
      children.select {|c| c.name == Note::TAG_NAME }.map! {|n| Note.new(n) }
    end

    def user_defined_encodings
      children.select {|c| c.name == UserDefinedEncoding::TAG_NAME }.map! {|n| UserDefinedEncoding.new(n) }
    end

    def properties
      children.select {|c| c.name == Property::TAG_NAME }.map! {|n| Property.new(n) }
    end

    # methods
    def can_contain?(element)
      [Note, UserDefinedEncoding, Property].any? {|c| c === element }
    end
  end
end
