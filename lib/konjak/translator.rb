require 'mem'
require 'konjak/tmx_segmentor'
require 'konjak/translator/translated_string'

module Konjak
  class Translator

    include Mem

    attr_reader :tmx, :src_lang, :target_lang, :options

    def initialize(tmx, src_lang, target_lang, **options)
      @tmx         = tmx
      @src_lang    = src_lang
      @target_lang = target_lang
      @options     = options
    end

    def translate(content)
      segmentor(content).segments.map do |text|
        next text unless text.is_a?(TmxSegmentor::SegmentString)
        source_segment = text.segment
        target_segment = source_segment.translation_unit.variant(target_lang).segment

        if format == :gtt_html || format == :gtt_polytex
          gtt_tags          = source_segment.extract_gtt_tags_from(text, format)
          translated_string = target_segment.interpolate_gtt_tags(gtt_tags, format)
          TranslatedString.new(translated_string, text)
        else
          TranslatedString.new(target_segment.text, text)
        end
      end
    end

    private

    def segmentor(content)
      TmxSegmentor.new(
        content,
        options.merge({
          tmx: tmx,
          lang: src_lang,
          format: format
        })
      )
    end

    def format
      options[:format]
    end
  end
end
