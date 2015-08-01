require 'mem'
require 'delegate'

module Konjak
  class Element < Delegator
    include Mem

    def initialize(__element__)
      @__element__ = __element__
    end

    def __getobj__
      @__element__
    end

    private

    def self.tmx_attr_accessor(name, attr_name=name, required: false)
      define_method(name) do
        self[attr_name]
      end

      define_method("#{name}=") do |value|
        self[attr_name] = value
      end
    end
  end
end
