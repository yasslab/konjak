module Konjak
  class Tmx < StructuralElement
    # required attr
    def version
      root[:version]
    end

    # required element
    def header
      Header.new(root.at_xpath('header'))
    end

    # required element
    def body
      Body.new(root.at_xpath('body'))
    end

    # FIXME
    #   One <header> followed by
    #   One <body> element.
    def can_contain?(element)
      Header === element || Body === element
    end
  end
end
