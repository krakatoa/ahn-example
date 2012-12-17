module Ivrzer
  class Action
    attr_reader :kind
    attr_reader :options
    
    def initialize(hash)
      @kind = hash[:kind]
      @options = hash[:options]

      #validate options for this kind: add validation method on each Action subclass

      hash[:rules] ||= []
      @rules = hash[:rules].collect {|rule_hash| Ivrzer::Rule.new(rule_hash) }
      # add rule method (e.g., build) that instantiates and validates the rule
    end

    def rules
      @rules
    end
    
    def next_action_id
      @rules.select { |rule| rule.kind == :next }[0].reference_id rescue nil
    end

    def self.build_action(action_hash)
      Kernel.const_get("Ivrzer").const_get("#{action_hash[:kind].to_s.capitalize}Action").new(action_hash)
    end
  end
end
