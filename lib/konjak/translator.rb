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
        s = tu.variant(src_lang).segment.text.to_s
        t = tu.variant(target_lang).segment.text.to_s
        translated_docs.map! { |d|
          next d if d.translated?
          next d if !d.include?(s)

          ds = []
          tail = nil
          loop do
            head, match, tail = d.partition(s)
            ds << head
            ds << TranslatedString.new(t)

            break unless tail.include?(s)

            d = tail
          end
          ds << tail
          ds
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
