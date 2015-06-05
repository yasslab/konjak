module Konjak
  class Tmx < StructuralElement
    # required attrs
    attr_accessor :version

    def initialize(tmx)
      super

      @version = tmx.root[:version]
      # TODO - better error handling
      @header = tmx.root.at_xpath('header')
      @body = tmx.root.at_xpath('body')
    end

    def header
      Header.new @header
    end

    def body
      Body.new @body
    end

    # FIXME
    #   One <header> followed by
    #   One <body> element.
    def can_contain?(element)
      Header === element || Body === element
    end
  end
end
