require 'delegate'

module Konjak
  class Element < Delegator
    attr_accessor :child_elements

    def initialize(__element__)
      @__element__ = __element__
    end

    def __getobj__
      @__element__
    end
  end
end
