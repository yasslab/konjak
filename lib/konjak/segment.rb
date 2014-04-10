module Konjak
  # container
  class Segment < StructuralElement
    def can_contain?(element)
      [Text, BeginPairedTag, EndPairedTag, IsolatedTag, Placeholder, Highlight].any? {|c| c === element }
    end
  end
end
