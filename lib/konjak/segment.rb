module Konjak
  # container
  class Segment < StructuralElement
    # children
    def text
      Text.new(super)
    end

    # methods
    def can_contain?(element)
      [Text, BeginPairedTag, EndPairedTag, IsolatedTag, Placeholder, Highlight].any? {|c| c === element }
    end
  end
end
