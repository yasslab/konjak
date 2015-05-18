require 'mem'
require 'konjak/translator/text_translate'
require 'konjak/translator/translated_string'

module Konjak
  class Translator

    using TextTranslate

    include Mem

    attr_reader :tmx, :src_lang, :target_lang

    def initialize(tmx, src_lang, target_lang)
      @tmx = tmx
      @src_lang = src_lang
      @target_lang = target_lang
    end

    def translate(doc)
      translated_docs = [doc.dup]
      translation_units.each do |tu|
        translated_docs.map! { |text|
          next text if text.is_a?(TranslatedString)

          tu.translate(src_lang, target_lang, text)
        }.flatten!
      end
      translated_docs.join
    end

    private

    def translation_units
      tmx.body.translation_units.select { |tu|
        tu.has_translation?(src_lang, target_lang)
      }.sort_by {|tu|
        -tu.variant(src_lang).segment.text.length
      }
    end
    memoize :translation_units
  end
end
