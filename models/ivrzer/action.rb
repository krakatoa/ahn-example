module Ivrzer
  class Action
    attr_reader :kind
    attr_reader :options
    
    def initialize(hash)
      @kind = hash[:kind]
      @options = hash[:options]

      #validate kind
      @rules = Ivrzer::Rule.build_rules_from_array(hash[:rules] || [])
      #validate rules
    end

    def next_action
      @rules.select { |rule| rule.kind == :next }[0]
    end

    def rules
      @rules
    end
  end
end
