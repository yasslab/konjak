require 'konjak/segmentor'

module Konjak
  class TmxSegmentor < Segmentor
    class SegmentString < String
      attr_accessor :segment

      def initialize(str, segment)
        super(str)
        @segment = segment
      end
    end
  end
end
