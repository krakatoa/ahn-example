module Ivrzer
  class AdhearsionRunner
    def initialize(ivr, call_controller=nil)
      @ivr = ivr
      @call_controller = call_controller
    end

    def run!
      next_action_id = @ivr.root_action_id

      begin
        current_action = @ivr.build_action(next_action_id)
        
        next_action_id = execute(current_action)

        next_action_id ||= execute(Ivrzer::HangupAction.dummy)
      end while next_action_id > 0

    end

    def execute(action)
      self.send(action.kind, action)
    end

    def menu(action)
      options = action.options
      options[:timeout] = options[:timeout].to_i.seconds
      @call_controller.menu options do
        action.matches.each do |match_rule|
          match_conditions = case match_rule.conditions[:type]
            when "digit"
              match_rule.conditions[:digit]
            when "range"
              match_rule.conditions[:from]..match_rule.conditions[:to]
          end

          match match_conditions do |digit|
            return match_rule.reference_id
          end

        end
      end

      return 0
    end

    def play(action)
      @call_controller.play *action.options[:sound]
      return action.next_action.reference_id rescue nil
    end

    def record(action)
      @call_controller.record action.options
      return action.next_action.reference_id rescue nil
    end

    def hangup(action)
      @call_controller.hangup
      return 0
    end

  end
end
