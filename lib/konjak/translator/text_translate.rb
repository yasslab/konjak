module Konjak
  class Translator
    module TextTranslate
      refine(TranslationUnit) do
        def translate(src_lang, target_lang, text)
          s = variant(src_lang).segment.text
          t = variant(target_lang).segment.text

          texts = []
          while true
            head, match, tail = text.partition(s)
            break if match.empty?
            texts << head unless head.empty?
            texts << TranslatedString.new(t)
            text = tail
          end
          texts << text
        end
      end
    end
  end
end
