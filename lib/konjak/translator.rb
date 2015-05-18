require 'mem'

module Konjak
  class Translator
    class TranslatedString < String
      def translated?
        true
      end
    end

    module Translate
      refine(String) do
        def translated?
          false
        end
      end

      refine(TranslationUnit) do
        def translate(src_lang, target_lang, text)
          s = variant(src_lang).segment.text.to_s
          t = variant(target_lang).segment.text.to_s

          unless text.include?(s)
            return text
          end

          texts = []
          loop do
            head, match, tail = text.partition(s)
            texts << head
            texts << TranslatedString.new(t)

            unless tail.include?(s)
              texts << tail
              break
            end

            text = tail
          end
          texts
        end
      end
    end

    using Translate

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
          next text if text.translated?

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
