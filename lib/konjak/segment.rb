module Konjak
  # container
  class Segment < StructuralElement
    def initialize(seg)
    end

    def can_contain?(element)
      [Text, BeginPairedTag, EndPairedTag, IsolatedTag, Placeholder, Highlight].any? {|c| c === element }
    end
  end
end
