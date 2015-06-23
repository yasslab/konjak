module Konjak
  class Translator
    class TranslatedString < String
      attr_accessor :source_str

      def initialize(str, source_str)
        super(str)
        @source_str = source_str
      end
    end
  end
end
