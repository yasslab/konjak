module Konjak
  class Segmentor
    attr_accessor :content, :options

    def initialize(content, options)
      @content = content
      @options = options
    end
  end
end
