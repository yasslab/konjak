module Konjak
  class Translator
    module GttHtmlTranslate
      refine(Text) do
        def gtt_tag_ns
          scan(/\{(\d+)\}/).flatten.uniq
        end

        def compile_gtt_html_pattern
          regexp = Regexp.escape(self)
          gtt_tag_ns.each do |n|
            regexp = regexp.sub(/\\\{#{n}\\\}/)    { "(?<n#{n}><(?<_#{n}>\\w+)[^>]*>)" }
            regexp = regexp.gsub(/\\\{#{n}\\\}/)   { "\\k<n#{n}>" }
            regexp = regexp.gsub(/\\\{\/#{n}\\\}/) { "</\\k<_#{n}>>" }
          end
          Regexp.compile(regexp)
        end

        def interpolate_gtt_html_pattern(match_data)
          new_text = dup
          gtt_tag_ns.each do |n|
            new_text = new_text.gsub("{#{n}}", match_data["n#{n}"])
            new_text = new_text.gsub("{/#{n}}", "</#{match_data["_#{n}"]}>")
          end
          new_text
        end
      end

      refine(TranslationUnit) do
        def translate(src_lang, target_lang, text)
          pattern     = variant(src_lang).segment.text.compile_gtt_html_pattern
          target_text = variant(target_lang).segment.text

          texts = []
          while true
            head, match, tail = text.partition(pattern)
            break if match.empty?
            texts << head unless head.empty?
            texts << TranslatedString.new(target_text.interpolate_gtt_html_pattern($~))
            text = tail
          end
          texts << text
        end
      end
    end
  end
end
