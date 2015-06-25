require 'mem'
require 'konjak/segmentor'
require 'konjak/tmx_segmentor/segment_string'

module Konjak
  class TmxSegmentor < Segmentor
    class Strategy
      include Mem

      def initialize(tmx, lang, options = {})
        @tmx = tmx
        @lang = lang
        @options = default_options.merge(options)
      end

      def segmentize(text)
        segments = [text]
        translation_units.each do |translation_unit|
          segments.map! {|text|
            next text if text.length < min_segment_length
            next text if text.is_a?(SegmentString)

            split(translation_unit, text)
          }.flatten!
        end
        segments
      end

      private

      def default_options
        {min_segment_length: 10}
      end

      def min_segment_length
        @options[:min_segment_length]
      end

      def translation_units
        @tmx.body.translation_units.sort_by {|tu|
          -tu.variant(@lang).segment.text.length
        }.reject {|tu|
          tu.variant(@lang).segment.text.length < min_segment_length
        }
      end
      memoize :translation_units
    end
  end
end
