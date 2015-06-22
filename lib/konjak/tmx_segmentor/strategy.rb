require 'mem'
require 'konjak/segmentor'
require 'konjak/tmx_segmentor/segment_string'

module Konjak
  class TmxSegmentor < Segmentor
    class Strategy
      include Mem

      def initialize(tmx, lang)
        @tmx = tmx
        @lang = lang
      end

      def segmentize(text)
        segments = [text]
        translation_units.each do |translation_unit|
          segments.map! {|text|
            next text if text.is_a?(SegmentString)

            split(translation_unit, text)
          }.flatten!
        end
        segments
      end

      private

      def translation_units
        @tmx.body.translation_units.sort_by {|tu|
          -tu.variant(@lang).segment.text.length
        }
      end
      memoize :translation_units
    end
  end
end
