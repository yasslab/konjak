module Konjak
  class Header < StructuralElement
    # required attrs
    attr_accessor :creation_tool, :creation_tool_version, :seg_type, :o_tmf, :admin_lang, :src_lang, :data_type

    # optional attrs
    attr_accessor :o_encoding, :creation_date, :creation_id, :change_date, :change_id

    # children
    attr_accessor :notes

    def initialize(header)
      # required attrs
      @creation_tool         = header[:creationtool]
      @creation_tool_version = header[:creationtoolversion]
      @seg_type              = header[:segtype]
      @o_tmf                 = header[:"o-tmf"]
      @admin_lang            = header[:adminlang]
      @src_lang              = header[:srclang]
      @data_type             = header[:datatype]

      # optional attrs
      @o_encoding    = header[:"o-encoding"]
      @creation_date = header[:creationdate]
      @creation_id   = header[:creationid]
      @change_date   = header[:changedate]
      @change_id     = header[:changeid]

      # children
      @notes = header.children.select {|c| c.name == 'note' }.map {|n| Note.new n }
    end

    def can_contain?(element)
      [Note, UserDefinedEncoding, Property].any? {|c| c === element }
    end
  end
end
