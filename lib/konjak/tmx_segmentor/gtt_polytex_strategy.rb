require 'konjak/tmx_segmentor/segment_string'
require 'konjak/tmx_segmentor/base_strategy'

module Konjak
  class TmxSegmentor < Segmentor
    class GttPolytexStrategy < BaseStrategy

      private

      def default_options
        super.merge(compile_pattern: -> (segment) { segment.compile_gtt_polytex_pattern })
      end
    end
  end
end
