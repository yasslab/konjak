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
      strategy.segments
    end

    private

    def tmx
      @options.fetch(:tmx)
    end

    def lang
      @options.fetch(:lang)
    end

    def format
      if STRATEGIES.has_key?(options[:format])
        options[:format]
      else
        :text
      end
    end

    def strategy
      STRATEGIES[format].new(tmx, lang, content, @options)
    end

  end
end
