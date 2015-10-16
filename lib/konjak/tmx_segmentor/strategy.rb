require 'mem'
require 'active_support'
require 'active_support/core_ext/object/try'
require 'konjak/segmentor'
require 'konjak/tmx_segmentor/segment_string'

module Konjak
  class TmxSegmentor < Segmentor
    Edge             = Struct.new(:left,  :right)
    RangeSegmentPair = Struct.new(:range, :segment)

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
            range_segment_pairs << RangeSegmentPair.new(($~.begin(0)...$~.end(0)), segment)
          }
        }

        # Can't split text
        return [text] if range_segment_pairs.empty?

        range_segment_pairs.uniq! {|rsp| [rsp.range, rsp.segment.text] }
        range_segment_pairs.sort_by! {|rsp|
          [rsp.range.begin, -rsp.segment.text.size]
        }

        max_weight_range_segments = max_weight_range_segments(range_segment_pairs)

        segments = []
        prev_text_index = 0
        max_weight_range_segments.each do |rsp|
          range     = rsp.range
          segment   = rsp.segment
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
        weights    = range_segment_pairs.map {|rsp| rsp.range.size }

        range_segment_pairs.each_with_index do |rsp, rsp_i|
          ((rsp_i + 1)...range_segment_pairs.size).each do |rsp2_i|
            rsp2 = range_segment_pairs[rsp2_i]

            next if rsp2.range.begin < rsp.range.end

            edges << Edge.new(rsp_i, rsp2_i)
          end
        end

        edges.each do |edge|
          rsp_i, rsp2_i = edge.left, edge.right
          new_rsp2_weight = weights[rsp_i] + range_segment_pairs[rsp2_i].range.size

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
        {}
      end

      def translation_unit_filter
        @options[:translation_unit_filter]
      end

      def translation_units
        if translation_unit_filter
          @translation_units ||= @tmx.body.translation_units.select(&translation_unit_filter)
        else
          @translation_units ||= @tmx.body.translation_units
        end
      end
    end
  end
end
