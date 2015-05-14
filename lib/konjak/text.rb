module Konjak
  class Text
    def initialize(text)
      @text = text
    end

    def to_s
      @text
    end

    def length
      @text.length
    end
  end
end
