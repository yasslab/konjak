require 'konjak/tmx_segmentor/segment_string'
require 'konjak/tmx_segmentor/strategy'

module Konjak
  class TmxSegmentor < Segmentor
    class TextStrategy < Strategy

      private

      def compile_pattern(segment)
        segment.compile_pattern
      end
    end
  end
end
