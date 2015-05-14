require 'mem'

module Konjak
  class Translator
    include Mem

    attr_reader :tmx, :src_lang, :target_lang

    def initialize(tmx, src_lang, target_lang)
      @tmx = tmx
      @src_lang = src_lang
      @target_lang = target_lang
    end

    def translate(doc)
      doc = doc.dup
      translation_units.each do |tu|
        s = tu.variants.detect { |v| v.xml_lang == src_lang }.segment.text.to_s
        t = tu.variants.detect { |v| v.xml_lang == target_lang }.segment.text.to_s
        doc.gsub!(s, t)
      end
      doc
    end

    private

    def translation_units
      tmx.body.translation_units.select { |tu|
        (!tu.src_lang || tu.src_lang == src_lang || tu.src_lang == '*all*') &&
        tu.variants.any? {|v| v.xml_lang == src_lang } &&
        tu.variants.any? {|v| v.xml_lang == target_lang }
      }.sort_by {|tu|
        -tu.variants.detect { |v| v.xml_lang == src_lang }.segment.text.length
      }
    end
    memoize :translation_units
  end
end
