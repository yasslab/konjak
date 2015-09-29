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
        range_segment_pairs = []

        translation_units.each {|tu|
          segment = tu.variant(@lang).segment
          text.scan(compile_pattern(segment)) {
            range_segment_pairs << [($~.begin(0)...$~.end(0)), segment]
          }
        }

        # Can't split text
        return [text] if range_segment_pairs.empty?

        range_segment_pairs.uniq! {|rsp| [rsp[0], rsp[1].text] }
        range_segment_pairs.sort_by! {|(m, s)|
          [m.begin, -s.text.size]
        }

        max_weight_range_segments = max_weight_range_segments(range_segment_pairs)

        segments = []
        prev_text_index = 0
        max_weight_range_segments.each do |(range, segment)|
          prev_text = text[prev_text_index...range.begin]

          segments << prev_text unless prev_text.empty?

          segments << SegmentString.new(text[range.begin, range.size], segment)

          prev_text_index = range.end
        end
        after_text = text[prev_text_index..-1]
        segments << after_text unless after_text.empty?
        segments
      end


      def max_weight_range_segments(range_segment_pairs)
        edges      = []
        prev_nodes = Array.new(range_segment_pairs.size, -1)
        weights    = range_segment_pairs.map {|rsp| rsp[0].size }

        range_segment_pairs.each_with_index do |rsp, rsp_i|
          ((rsp_i + 1)...range_segment_pairs.size).each do |rsp2_i|
            rsp2 = range_segment_pairs[rsp2_i]

            next if rsp2[0].begin < rsp[0].end

            edges << [rsp_i, rsp2_i]
          end
        end

        edges.each do |(rsp_i, rsp2_i)|
          new_rsp2_weight = weights[rsp_i] + range_segment_pairs[rsp2_i][0].size

          if weights[rsp2_i] < new_rsp2_weight
            weights[rsp2_i] = new_rsp2_weight
            prev_nodes[rsp2_i] = rsp_i
          end
        end

        node_index = weights.index(weights.max)

        max_weight_range_segment_indexes = Enumerator.new {|y|
          loop do
            break if node_index == -1
            y << node_index
            node_index = prev_nodes[node_index]
          end
        }.to_a.reverse

        max_weight_range_segment_indexes.map {|i|
          range_segment_pairs[i]
        }
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

      def translation_units
        @translation_units ||= @tmx.body.translation_units.select {|tu|
          segment = tu.variant(@lang).segment
          segment_length = segment.text.length

          next false if segment_length < min_segment_length
          next false if max_segment_length && max_segment_length < segment_length

          true
        }
      end
    end
  end
end
