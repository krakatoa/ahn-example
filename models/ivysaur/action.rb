module Ivysaur
  class Action
    @@actions = [:menu, :play, :match, :logger]
  
    def initialize(ivr, current_scope)
      @ivr = ivr
      @scope = current_scope
    end
  
    def renderer
      @ivr.renderer
    end
  
    def scope
      @scope
    end
  
    def attributes
      @scope[:attributes]
    end
  
    def output(env={})
      renderer.send(kind, self.attributes, self.actions, env)
    end
  
    def actions
      return [] if not @scope.has_key?(:actions)
      @scope[:actions].inject([]) { |actions, action_hash|
        key, value = action_hash.keys[0], action_hash.values[0] # should validate that only one pair of key values exist
        actions << Kernel.const_get("Ivysaur").const_get(key.to_s.capitalize).new(@ivr, value) if Ivysaur::Action.actions.include?(key)
        actions
      } 
    end
    
    def self.actions
      @@actions
    end
  end
end
