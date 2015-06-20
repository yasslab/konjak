module Konjak
  class PolytexSegmentor < Segmentor
    def segments
      segments = [content.dup]

      begin
        size = segments.size

        segments_patterns = [
          /\\begin\{(?<start>[^\}]+)\}([\n.]*?)\\end\{\k<start>\}/m,
          /(?<=\\chapter\{)[^\}]+(?=\})/,
          /(?<=\\section\{)[^\}]+(?=\})/,
          /(?<=\\subsection\{)[^\}]+(?=\})/,
          /\\footnote\{(?<gr>\\(?!footnote)[^\{]+\{[^\}]+\}(?:\{[^\}]+\})?\g<gr>|[^{])+\}/m,
          /(?<=\\footnote\{)(?<gr>\\(?!footnote)[^\{]+\{[^\}]+\}(?:\{[^\}]+\})?\g<gr>|[^{])+(?=\})/m,
          /(?<=\\codecaption\{).+(?= \\|\}$)/,
          /(?<=\\caption\{).+(?=\\label\{.*\}\}$)/,
          /(?<=\n)^.*$(?=\n)/m,
          /# .*$/,
          /(?<=^).+?[\.\?\!](?= |\n|\t)/,
          /(?<=\()[^\.\n]+[\.\?\!](?=\))/,
          /^ (?=[\w\\]+)/,
          /^\s+% .*$/,
          /^$/,
          /\\noindent /,
          /\\item /,
        ]
        segments_patterns.each do |pattern|
          segments.map! do |s|
            s.partition(pattern)
          end
          segments.flatten!
          segments.reject!(&:empty?)
        end
      end while segments.size != size

      segments
    end
  end
end
