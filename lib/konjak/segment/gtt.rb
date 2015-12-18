require 'mem'

module Konjak
  class Segment < StructuralElement
    module GTT
      include Mem

      Tag = Struct.new(:gtt, :matched)

      def compile_gtt_polytex_pattern
        pattern_text = text.rstrip
        pattern_text.gsub!(/(?:\.|:)\{\d+\}\{\d+\}\d+\{\/\d+\}\{\/\d+\}$/, '') # ignore footnote link
        regexp = Regexp.escape(pattern_text)
        regexp.gsub!(/\\}\\ (?!\\ )/)  { '\\}\\\\?\\ ' }
        regexp.gsub!(/–/) { "(?:--|–)" }
        regexp.gsub!(/—/) { "(?:---|—)" }
        regexp.gsub!(/’/) { "(?:’|')" }
        regexp.gsub!(/“/) { "(?:“|``)"}
        regexp.gsub!(/”/) { "(?:”|'')"}
        regexp.gsub!(/\\\{(?<n1>\d+)\\\}(?:(?<type>Chapter|Figure|Listing|Section|Table)(?:\u00A0|\\\ ))\\\{(?<n2>\d+)\\}\d+(?:\\.\d+|)(?:\\.\d+|)\\\{\/\k<n2>\\\}\\\{\/\k<n1>\\\}/) {
          m = $~
          if m[:type]
            "#{m[:type]}~(?<p#{m[:n1]}>\\\\ref{(?:cha|fig|code|sec|table):[^}]+})"
          else
            "(?<p#{m[:n1]}>\\\\ref{(?:cha|fig|code|sec|table):[^}]+})"
          end
        }
        gtt_tag_ns.each do |n|
          regexp.gsub!(/(?<=\\\{#{n}\\\})(?<content>.*)(?=\\\{\/#{n}\\\})/) { $~[:content].gsub(/(?<!\(\?\:)_(?!\))/, '(?:_|\\\\\\\\_)') }
          regexp.sub!(/\\\{#{n}\\\}/)    { "(?<n#{n}>(?:\\\\texttt\\{|\\\\kode\\{|\\\\emph\\{|\\\\href\\{[^\\}]*\\}\\{))" }
          regexp.gsub!(/\\\{#{n}\\\}/)   { "\\k<n#{n}>" }
          regexp.gsub!(/\\\{\/#{n}\\\}/) { "(?<nc#{n}>\\})" }
        end
        regexp.gsub!(/\\\s/)                { '\s' }
        regexp.gsub!(/(?<!\\s|\\)\\s(?!\\s)/, '(?:\s|~)')
        regexp.gsub!(/(?<!^|\\)(?:\\s)+(?!$)/) {|s| "(?:\\\\linebreak|#{s})++" }
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

        gtt_tags = []
        gtt_tag_ns.each do |n|
          if m.names.include?("n#{n}") && m["n#{n}"]
            gtt_tags << Tag.new("{#{n}}", m["n#{n}"])
            gtt_tags << Tag.new("{/#{n}}",m["nc#{n}"])
          end
        end

        m.names.select {|n| n.starts_with?('p') }.each do |pn|
          if m[pn].starts_with?('\ref')
            gtt_tags << Tag.new("{#{pn}}", m[pn])
          end
        end

        gtt_tags
      end

      def interpolate_gtt_tags(tags, format)
        new_text = self.text.dup

        if format == :gtt_polytex
          new_text.rstrip!
          new_text.gsub!(/(。|:)?\{\d+\}\{\d+\}\d+\{\/\d+\}\{\/\d+\}(。|:)?$/, '') # ignore footnote link
          new_text.gsub!(/\{(?<n1>\d+)\}(?:(?<type>[^\}]+(?:\u00A0| )*)|)\{(?<n2>\d+)\}\d+.\d+(?:.\d+|)\{\/\k<n2>\}\{\/\k<n1>\}/) {
            m = $~
            if m[:type]
              "#{m[:type]}{p#{m[:n1]}}"
            else
              "{p#{m[:n1]}}"
            end
          }
        end

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
