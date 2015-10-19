require 'mem'
require 'active_support'
require 'active_support/core_ext/object/try'
require 'konjak/segmentor'
require 'konjak/tmx_segmentor/segment_string'

module Konjak
  class TmxSegmentor < Segmentor
    class Strategy
      Edge = Struct.new(:prev,  :current)
      Node = Struct.new(:range, :segment) do
        def <=>(other)
          [range.begin, -segment.text.size] <=> [other.range.begin, -other.segment.text.size]
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
        prev_text_index = 0
        max_cost_path.each do |node|
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
          ((node_i + 1)...nodes.size).each do |node2_i|
            node2 = nodes[node2_i]

            next if node2.range.begin < node.range.end

            @edges << Edge.new(node, node2)
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

        @nodes.sort!

        @nodes
      end

      def default_options
        {
          translation_unit_filter: -> (tu) { true },
          calc_edge_cost:  -> (edge) { edge.current.segment.size }
        }
      end

      def calc_edge_cost(edge)
        @options[:calc_edge_cost].call(edge)
      end

      def translation_unit_filter
        @options[:translation_unit_filter]
      end

      def translation_units
        @translation_units ||= @tmx.body.translation_units.select(&translation_unit_filter)
      end
    end
  end
end
