require 'mem'
require 'active_support'
require 'active_support/core_ext/object/try'
require 'konjak/segmentor'
require 'konjak/tmx_segmentor/segment_string'

module Konjak
  class TmxSegmentor < Segmentor
    class BaseStrategy
      Edge = Struct.new(:prev,  :current)
      Node = Struct.new(:range, :segments) do
        def <=>(other)
          [range.begin, -max_segment_size] <=> [other.range.begin, -other.max_segment_size]
        end

        def max_segment_size
          segments.max_by {|s| s.text.size }.text.size
        end
      end
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

        segments = []
        prev_text_end = 0
        prev_segment = nil
        max_cost_path.each do |node|
          range     = node.range
          segment   = select_next_segment(prev_segment, node)
          prev_text = @text[prev_text_end...range.begin]

          segments << prev_text unless prev_text.empty?

          segments << SegmentString.new(@text[range.begin, range.size], segment)

          prev_segment    = segment
          prev_text_end = range.end
        end
        after_text = @text[prev_text_end..-1]
        segments << after_text unless after_text.empty?
        segments
      end


      def max_cost_path
        prev_nodes = nodes.map {|node| [node, Node::None] }.to_h
        costs      = nodes.map {|node| [node, node.range.size] }.to_h

        edges.each do |edge|
          node, node2    = edge.prev, edge.current
          node2_cost     = costs[node2]
          new_node2_cost = costs[node] + calc_edge_cost(edge)

          if node2_cost < new_node2_cost
            costs[node2] = new_node2_cost
            prev_nodes[node2] = node
          end
        end

        node, _ = costs.max_by {|_, cost| cost }

        Enumerator.new {|y|
          loop do
            break if node == Node::None
            y << node
            node = prev_nodes[node]
          end
        }.to_a.reverse
      end

      private

      def edges
        return @edges if @edges

        @edges     = []
        nodes.each_with_index do |node, node_i|
          next_node_first = nil
          ((node_i+1)...nodes.size).each_with_index {|node2_i|
            node2 = nodes[node2_i]
            next if node2.range.begin < node.range.end

            next_node_first ||= node2

            break if node2.range.begin >= next_node_first.range.end

            @edges << Edge.new(node, node2)
          }
        end

        @edges
      end

      def nodes
        return @nodes if @nodes

        @nodes = {}

        translation_units.each {|tu|
          segment = tu.variant(@lang).segment
          @text.scan(compile_pattern(segment)) {
            r = $~.begin(0)...$~.end(0)
            @nodes[r] ||= []
            @nodes[r] << segment
          }
        }
        @nodes = @nodes.map {|(r, segments)| Node.new(r, segments) }
        @nodes.sort!

        @nodes
      end

      def default_options
        {
          calc_edge_cost:          -> (edge)    { edge.current.max_segment_size },
          compile_pattern:         -> (segment) { segment.compile_pattern },
          select_next_segment:     -> (_, node) { node.segments.first },
          translation_unit_filter: -> (tu)      { true },
        }
      end

      def calc_edge_cost(edge)
        @options[:calc_edge_cost].call(edge)
      end

      def compile_pattern(segment)
        @options[:compile_pattern].call(segment)
      end

      def translation_unit_filter
        @options[:translation_unit_filter]
      end

      def select_next_segment(prev_segment, node)
        @options[:select_next_segment].call(prev_segment, node)
      end

      def translation_units
        @translation_units ||= @tmx.body.translation_units.select(&translation_unit_filter)
      end
    end
  end
end
