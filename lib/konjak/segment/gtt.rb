require 'mem'

module Konjak
  class Segment < StructuralElement
    module GTT
      include Mem

      Tag = Struct.new(:gtt, :html)

      def compile_gtt_html_pattern
        regexp = Regexp.escape(text)
        gtt_tag_ns.each do |n|
          regexp.sub!(/\\\{#{n}\\\}/)    { "(?<n#{n}><(?<_#{n}>\\w+)[^>]*>)" }
          regexp.gsub!(/\\\{#{n}\\\}/)   { "\\k<n#{n}>" }
          regexp.gsub!(/\\\{\/#{n}\\\}/) { "</\\k<_#{n}>>" }
        end
        regexp.gsub!(/\\\s/)                { '\s' }
        regexp.gsub!(/(?<!^)(?:\\s)+(?!$)/) {|s| s + '++' }
        Regexp.compile(regexp)
      end
      memoize :compile_gtt_html_pattern

      def extract_gtt_tags_from(text)
        m = text.match(compile_gtt_html_pattern)
        gtt_tag_ns.each_with_object([]) do |n, tags|
          tags << Tag.new("{#{n}}", m["n#{n}"])
          tags << Tag.new("{/#{n}}", "</#{m["_#{n}"]}>")
        end
      end

      def interpolate_gtt_tags(tags)
        new_text = self.text.dup
        tags.each do |tag|
          new_text = new_text.gsub(tag[:gtt], tag[:html])
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
