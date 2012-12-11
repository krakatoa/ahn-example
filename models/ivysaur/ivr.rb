module Ivysaur
  class Ivr < Ivysaur::Action
    attr_accessor :renderer
    
    def initialize(hash)
      @ivr = self
      @scope = hash
    end

    def menu
      # ivr should contain a single menu
      # actions.select { |action| action.kind == :menu }
    end

    def kind
      :ivr
    end
  end
end
