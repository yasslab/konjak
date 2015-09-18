require 'mem'
require 'active_support'
require 'active_support/core_ext/object/try'
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
        translation_units(text).each do |translation_unit|
          segment = translation_unit.variant(@lang).segment

          pat = compile_pattern(segment)

          segments.map! {|text|
            next text if text.length < min_segment_length
            next text if text.is_a?(SegmentString)

            split(pat, segment, text)
          }.flatten!
        end
        segments
      end

      private

      def default_options
        {
          min_segment_length: 10,
          max_segment_length: nil
        }
      end

      def min_segment_length
        @options[:min_segment_length]
      end

      def max_segment_length
        @options[:max_segment_length]
      end

      def split(pat, segment, text)
        texts = []
        while true
          break if text.length < min_segment_length

          break unless text =~ pat

          head  = $`
          match = $&
          tail  = $'

          texts << head unless head.empty?

          texts << SegmentString.new(match, segment)

          text = tail
        end
        texts << text
      end

      def translation_units(text)
        tus = @tmx.body.translation_units

        tus.select! {|tu|
          segment = tu.variant(@lang).segment
          segment_length = segment.text.length

          next false if segment_length < min_segment_length
          next false if max_segment_length && max_segment_length < segment_length

          text =~ compile_pattern(tu.variant(@lang).segment)
        }

        simular_translation_units_map = {}

        tus.sort_by! {|tu|
          tu_segment = tu.variant(@lang).segment
          segment_text = tu_segment.text

          unless simular_translation_units_map[segment_text]
            simular_translation_units = tus.select {|tu2|
              tu2.variant(@lang).segment.text =~ compile_pattern(tu_segment)
            }.sort_by! {|tu2| tu2.variant(@lang).segment.text.size }

            simular_translation_units.each do |tu2|
              simular_translation_units_map[tu2.variant(@lang).segment.text] = simular_translation_units
            end
          end

          rank = simular_translation_units_map[segment_text].index {|tu2|
            tu2.variant(@lang).segment.text == segment_text
          }

          # GTTの場合
          translation_timestamp = nil
          if tm_entry = tu.at('entry_metadata').try(:at, 'tm_entry')
            source_info = tm_entry.at('source_info')
            if source_info.try(:at, 'source_lang').try(:text) == @lang && source_info.try(:at, 'source').try(:text) == segment_text
              translation_timestamp = tm_entry.at('translation').try(:attr, 'translation_timestamp').to_i
            end
          end
          translation_timestamp ||= 0

          [-rank, -translation_timestamp, -segment_text.length]
        }

        tus
      end
    end
  end
end
