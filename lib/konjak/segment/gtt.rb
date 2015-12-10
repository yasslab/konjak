require 'mem'

module Konjak
  class Segment < StructuralElement
    module GTT
      include Mem

      Tag = Struct.new(:gtt, :matched)

      def compile_gtt_polytex_pattern
        regexp = Regexp.escape(text)
        gtt_tag_ns.each do |n|
          regexp.sub!(/\\\{#{n}\\\}/)    { "(?<n#{n}>(?:\\\\emph\\{|\\\\href\\{[^\\}]*\\}\\{))" }
          regexp.gsub!(/\\\{#{n}\\\}/)   { "\\k<n#{n}>" }
          regexp.gsub!(/\\\{\/#{n}\\\}/) { "(?<nc#{n}>\\})" }
        end
        regexp.gsub!(/\\\s/)                { '\s' }
        regexp.gsub!(/(?<!^)(?:\\s)+(?!$)/) {|s| s + '++' }
        Regexp.compile(regexp)
      end

      def compile_gtt_html_pattern
        regexp = Regexp.escape(text)
        gtt_tag_ns.each do |n|
          regexp.sub!(/\\\{#{n}\\\}/)    { "(?<n#{n}><(?<_#{n}>\\w+)[^>]*>)" }
          regexp.gsub!(/\\\{#{n}\\\}/)   { "\\k<n#{n}>" }
          regexp.gsub!(/\\\{\/#{n}\\\}/) { "(?<nc#{n}></\\k<_#{n}>>)" }
        end
        regexp.gsub!(/\\\s/)                { '\s' }
        regexp.gsub!(/(?<!^)(?:\\s)+(?!$)/) {|s| s + '++' }
        Regexp.compile(regexp)
      end

      def extract_gtt_tags_from(text, format)
        if format == :gtt_html
          m = text.match(compile_gtt_html_pattern)
        elsif format == :gtt_polytex
          m = text.match(compile_gtt_polytex_pattern)
        else
          raise "Unknown format: #{format}"
        end
        gtt_tag_ns.each_with_object([]) do |n, tags|
          tags << Tag.new("{#{n}}", m["n#{n}"])
          tags << Tag.new("{/#{n}}",m["nc#{n}"])
        end
      end

      def interpolate_gtt_tags(tags)
        new_text = self.text.dup
        tags.each do |tag|
          new_text = new_text.gsub(tag[:gtt], tag[:matched])
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
