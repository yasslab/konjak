require 'mem'
require 'konjak/tmx_segmentor'

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
        target_segment.interpolate_gtt_tags(source_segment.gtt_tags(text))
      end
    end

    private

    def segmentor(content)
      TmxSegmentor.new(
        content,
        tmx: tmx,
        lang: src_lang,
        format: options[:format]
      )
    end
  end
end
