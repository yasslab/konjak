require 'mem'
require 'active_support'
require 'active_support/core_ext/object/try'
require 'konjak/segmentor'
require 'konjak/tmx_segmentor/segment_string'

module Konjak
  class TmxSegmentor < Segmentor
    class Strategy
      Edge = Struct.new(:prev,  :current)
      Node = Struct.new(:range, :segment)
      Node::None = -1

      include Mem

      def initialize(tmx, lang, text, options = {})
        @tmx     = tmx
        @lang    = lang
        @text    = text
        @options = default_options.merge(options)
      end

      def segments
        # Can't split text
        return [@text] if nodes.empty?

        max_weight_range_segments = self.max_weight_range_segments

        segments = []
        prev_text_index = 0
        max_weight_range_segments.each do |node|
          range     = node.range
          segment   = node.segment
          prev_text = @text[prev_text_index...range.begin]

          segments << prev_text unless prev_text.empty?

          segments << SegmentString.new(@text[range.begin, range.size], segment)

          prev_text_index = range.end
        end
        after_text = @text[prev_text_index..-1]
        segments << after_text unless after_text.empty?
        segments
      end


      def max_weight_range_segments
        prev_nodes = Array.new(nodes.size, Node::None)
        weights    = nodes.map {|node| node.range.size }

        edges.each do |edge|
          node_i, node2_i = edge.prev, edge.current
          new_node2_weight = weights[node_i] + nodes[node2_i].range.size

          if weights[node2_i] < new_node2_weight
            weights[node2_i] = new_node2_weight
            prev_nodes[node2_i] = node_i
          end
        end

        node_index = weights.index(weights.max)

        max_weight_range_segment_indexes = Enumerator.new {|y|
          loop do
            break if node_index == Node::None
            y << node_index
            node_index = prev_nodes[node_index]
          end
        }.to_a.reverse

        max_weight_range_segment_indexes.map {|i|
          nodes[i]
        }
      end

      private

      def edges
        return @edges if @edges

        @edges     = []
        nodes.each_with_index do |node, node_i|
          ((node_i + 1)...nodes.size).each do |node2_i|
            node2 = nodes[node2_i]

            next if node2.range.begin < node.range.end

            @edges << Edge.new(node_i, node2_i)
          end
        end

        @edges
      end

      def nodes
        return @nodes if @nodes

        @nodes = []

        translation_units.each {|tu|
          segment = tu.variant(@lang).segment
          @text.scan(compile_pattern(segment)) {
            @nodes << Node.new(($~.begin(0)...$~.end(0)), segment)
          }
        }

        @nodes.uniq! {|node| [node.range, node.segment.text] }
        @nodes.sort_by! {|node| [node.range.begin, -node.segment.text.size] }

        @nodes
      end

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
