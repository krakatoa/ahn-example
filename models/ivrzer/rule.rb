module Ivrzer
  class Rule
    attr_reader :kind
    attr_reader :conditions
    attr_reader :reference_id
    
    def initialize(hash)
      @kind = hash[:kind]
      @conditions = hash[:conditions]
      @reference_id = hash[:reference_id]
    end

  end
end
