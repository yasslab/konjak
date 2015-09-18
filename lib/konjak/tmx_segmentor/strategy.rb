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
          text =~ compile_pattern(tu.variant(@lang).segment)
        }

        tus.sort_by! {|tu|
          # GTTの場合
          translation_timestamp = nil

          if tm_entry = tu.at('entry_metadata').try(:at, 'tm_entry')
            source_info = tm_entry.at('source_info')
            if source_info.try(:at, 'source_lang').try(:text) == @lang && source_info.try(:at, 'source').try(:text) == tu.variant(@lang).segment.text
              translation_timestamp = tm_entry.at('translation').try(:attr, 'translation_timestamp').to_i
            end
          end

          translation_timestamp ||= 0

          segment_length = tu.variant(@lang).segment.text.length

          [-translation_timestamp, -segment_length]
        }

        tus.reject! {|tu|
          segment_length = tu.variant(@lang).segment.text.length
          next true if segment_length < min_segment_length
          next true if max_segment_length && max_segment_length < segment_length
          false
        }

        tus
      end
    end
  end
end
