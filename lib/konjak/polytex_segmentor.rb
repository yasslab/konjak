module Konjak
  class PolytexSegmentor < Segmentor

    SEGMENTS_PATTERNS = [
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

    def segments
      segments = [content.dup]

      begin
        size = segments.size

        SEGMENTS_PATTERNS.each do |pattern|
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
