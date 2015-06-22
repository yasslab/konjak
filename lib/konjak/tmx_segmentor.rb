require 'konjak/segmentor'
require 'konjak/tmx_segmentor/gtt_html_strategy'
require 'konjak/tmx_segmentor/text_strategy'

module Konjak
  class TmxSegmentor < Segmentor

    STRATEGIES = {
      text:     TextStrategy,
      gtt_html: GttHtmlStrategy,
    }

    def segments
      strategy.segmentize(content)
    end

    private

    def tmx
      @options[:tmx] or raise 'tmx option is not set'
    end

    def lang
      @options[:lang] or raise 'lang option is not set'
    end

    def format
      if STRATEGIES.has_key?(options[:format])
        options[:format]
      else
        :text
      end
    end

    def strategy
      STRATEGIES[format].new(tmx, lang)
    end

  end
end
