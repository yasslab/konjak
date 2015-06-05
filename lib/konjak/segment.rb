module Konjak
  # container
  class Segment < StructuralElement
    # children
    attr_accessor :text

    def initialize(seg)
      super

      @text = Text.new(seg.text)
    end

    def can_contain?(element)
      [Text, BeginPairedTag, EndPairedTag, IsolatedTag, Placeholder, Highlight].any? {|c| c === element }
    end
  end
end
