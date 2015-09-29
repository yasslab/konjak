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
            # Struct.new(:range, :segment, :prev)
            range_segment_pairs << [($~.begin(0)...$~.end(0)), segment]
          }
        }

        # Can't split text
        return [text] if range_segment_pairs.empty?

        range_segment_pairs.uniq!(&:first)
        range_segment_pairs.sort_by! {|(m, _)| m.begin }

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


      def weights_and_prev_nodes(range_segment_pairs)
        prev_nodes = Array.new(range_segment_pairs.size, -1)
        weights = Array.new(range_segment_pairs.size, 0)

        (0...range_segment_pairs.size).each do |i|
          rsp = range_segment_pairs[i]
          if prev_nodes[i] == -1
            weights[i] = rsp[0].size
            next
          end

          if prev_nodes[i]
            new_weight = rsp[0].size
          else
            new_weight = weights[prev_nodes[i]] + rsp[0].size
          end

          if weights[i] < new_weight
            weights[i] = new_weighta
            prev_nodes[i] = prev_nodes[i]
          end
        end

        [weights, prev_nodes]
      end

      def max_covered_path(range_segment_pairs)
        edges = []

        range_segment_pairs.each_with_index do |rsp, rsp_i|
          ((rsp_i + 1)...range_segment_pairs.size).each {|next_rsp_i|
            next_rsp = range_segment_pairs[next_rsp_i]
            if next_rsp && next_rsp[0].begin < rsp[0].end
              edges << [rsp_i, next_rsp_i]
            end
          }
        end

        nodes = Array.new(range_segment_pairs.size)

        nodes.each_with_index do |node, rsp_i|
          nodes[]
        end
      end

      def max_covered_path(range_segment_pairs)
        rsp_i_path_pairs = [[0, []]]

        max_covered_path = nil
        max_covered_size = 0

        loop do
          break if rsp_i_path_pairs.empty?

          rsp_i, path = rsp_i_path_pairs.pop

          cur_pair = range_segment_pairs[rsp_i]
          next_pair = range_segment_pairs[rsp_i + 1]

          p rsp_i_path_pairs
          p rsp_i_path_pairs.count

          unless next_pair
            covered_size = path.inject(0) {|size, i| size + range_segment_pairs[i][0].size }

            if covered_size > max_covered_size
              max_covered_path = path
              max_covered_size = covered_size
            end

            next
          end

          if next_pair[0].begin < cur_pair[0].end
            rsp_i_path_pairs.push([rsp_i + 1, path + [rsp_i]])
          else
            rsp_i_path_pairs.push([rsp_i + 1, path])
            rsp_i_path_pairs.push([rsp_i + 1, path + [rsp_i]])
          end
        end

        max_covered_path
      end


      # def max_covered_path(range_segment_pairs, range_segment_pair_index, path)
      #   cur_pair  = range_segment_pair_index[range_segment_pair_index]
      #   next_pair = range_segment_pair_index[range_segment_pair_index + 1]
      #
      #   return path unless next_pair
      #
      #   path1 = max_covered_path(range_segment_pairs, range_segment_pair_index + 1, path + [range_segment_pair_index])
      #   return path1 unless next_pair[0].cover?(cur_pair[0].end(0))
      #
      #   path2 = max_covered_path(range_segment_pairs, range_segment_pair_index + 1, path)
      #
      #   [path1, path2].max_by {|path|
      #     path.inject(0) {|size, i| size + range_segment_pairs[i][0].size }
      #   }
      # end

      # def segmentize(text)
      #   text_len = text.length
      #   segments_marks = Array.new(translation_units.size) {|i|
      #     Array.new(test_len).tap {|a|
      #       segment = translation_units[i].variant(@lang).segment
      #       text.scan(compile_pattern(segment)) {
      #         ($~.begin(0)...$~.end(0)).each {|j|
      #           a[j] = true
      #         }
      #       }
      #     }
      #   }
      # end

      # def segmentize(text)
      #   segments = [text]
      #   translation_units(text).each do |translation_unit|
      #     segment = translation_unit.variant(@lang).segment
      #
      #     pat = compile_pattern(segment)
      #
      #     segments.map! {|text|
      #       next text if text.length < min_segment_length
      #       next text if text.is_a?(SegmentString)
      #
      #       split(pat, segment, text)
      #     }.flatten!
      #   end
      #   segments
      # end

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
