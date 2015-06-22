module Konjak
  class Segment < StructuralElement
    module GTT
      def compile_gtt_html_pattern
        regexp = Regexp.escape(text)
        gtt_tag_ns.each do |n|
          regexp = regexp.sub(/\\\{#{n}\\\}/)    { "(?<n#{n}><(?<_#{n}>\\w+)[^>]*>)" }
          regexp = regexp.gsub(/\\\{#{n}\\\}/)   { "\\k<n#{n}>" }
          regexp = regexp.gsub(/\\\{\/#{n}\\\}/) { "</\\k<_#{n}>>" }
        end
        Regexp.compile(regexp)
      end

      def gtt_tags(text)
        m = text.match(compile_gtt_html_pattern)
        gtt_tag_ns.each_with_object({}) do |n, tags|
          tags[n] = {
            open: m["n#{n}"], close:"</#{m["_#{n}"]}>"
          }
        end
      end

      def interpolate_gtt_tags(tags)
        new_text = self.text.dup
        gtt_tag_ns.each do |n|
          new_text = new_text.gsub("{#{n}}", tags[n][:open])
          new_text = new_text.gsub("{/#{n}}", tags[n][:close])
        end
        new_text
      end

      private

      def gtt_tag_ns
        text.scan(/\{(\d+)\}/).flatten.uniq
      end
    end
  end
end
