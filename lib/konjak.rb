require 'konjak/version'
require 'konjak/parser'

# not elements
require 'konjak/code_data'

# elements
require 'konjak/element'
require 'konjak/inline_element'
require 'konjak/structural_element'

# structural elements
require 'konjak/body'
require 'konjak/header'
require 'konjak/map'
require 'konjak/note'
require 'konjak/property'
require 'konjak/segment'
require 'konjak/tmx'
require 'konjak/translation_unit'
require 'konjak/translation_unit_variant'
require 'konjak/user_defined_encoding'

# inline elements
require 'konjak/begin_paired_tag'
require 'konjak/end_paired_tag'
require 'konjak/highlight'
require 'konjak/isolated_tag'
require 'konjak/placeholder'
require 'konjak/sub_flow'
require 'konjak/unknown_tag'

# translator
require 'konjak/translator'

# segmentor
require 'konjak/segmentor'
require 'konjak/html_segmentor'
require 'konjak/polytex_segmentor'
require 'konjak/tmx_segmentor'

module Konjak
  class << self
    def parse(xml, **options)
      Parser.new(**options).parse(xml)
    end

    def translate(doc, xml_or_tmx, src_lang, target_lang, **options)
      tmx = xml_or_tmx.kind_of?(Tmx) ? xml_or_tmx : parse(xml_or_tmx, **options)
      Translator.new(tmx, src_lang, target_lang, **options).translate(doc)
    end
  end
end
