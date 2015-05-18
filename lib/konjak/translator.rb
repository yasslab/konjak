require 'mem'
require 'konjak/translator/text_translate'
require 'konjak/translator/translated_string'

module Konjak
  class Translator

    include Mem

    attr_reader :tmx, :src_lang, :target_lang, :options

    def initialize(tmx, src_lang, target_lang, **options)
      @tmx         = tmx
      @src_lang    = src_lang
      @target_lang = target_lang
      @options     = options
    end

    def translate(doc)
      translated_docs = [doc.dup]
      translation_units.each do |tu|
        translated_docs.map! { |text|
          next text if text.is_a?(TranslatedString)

          env = translate_env.dup
          env.local_variable_set(:tu, tu)
          env.local_variable_set(:src_lang, src_lang)
          env.local_variable_set(:target_lang, target_lang)
          env.local_variable_set(:text, text)
          eval('tu.translate(src_lang, target_lang, text)', env)
        }.flatten!
      end
      translated_docs.join
    end

    private

    TRANSLATE_ENVS= {
      text:     Class.new { using TextTranslate; break binding }
    }

    def format
      options[:format] || :text
    end

    def translate_env
      TRANSLATE_ENVS[format]
    end

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
