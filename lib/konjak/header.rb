module Konjak
  class Header < StructuralElement
    # required attrs
    attr_accessor :creation_tool, :creation_tool_version, :seg_type, :o_tmf, :admin_lang, :src_lang, :data_type

    # optional attrs
    attr_accessor :o_encoding, :creation_date, :creation_id, :change_date, :change_id

    def can_contain?(element)
      [Note, UserDefinedEncoding, Property].any? {|c| c === element }
    end
  end
end
