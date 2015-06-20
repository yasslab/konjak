module Konjak
  class HtmlSegmentor < Segmentor
    def segments
      segments = [content.dup]

      begin
        size = segments.size

        segments_patterns = [
          %r{<(?<start>p|h1|h2|h3|h4|h5|h6|li|title|td)>(.*?)</\k<start>>}m,
          %r{<(?<start>p|h1|h2|h3|h4|h5|h6|li|title|td) [^>]*?>(.*?)</\k<start>>}m,
          %r{<div>(.*?)</div>}m,
          %r{<div [^>]*?>(.*?)</div>}m
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
