module Ivrzer
  class Runner
    def initialize(ivr, call_controller=nil)
      @ivr = ivr
      @call_controller = call_controller
    end

    def run!
      run_chain(@ivr.root_action_id)
    end

    private
    def execute(action)
      self.send(action.kind, action)
    end

    def run_chain(action_id)
      next_action_id = action_id

      begin
        current_action = @ivr.build_action(next_action_id)

        next_action_id = execute(current_action)

        next_action_id ||= 0 # execute(Ivrzer::HangupAction.dummy)
      end while next_action_id > 0
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
            when "pattern"
              match_rule.conditions[:pattern]
          end

          match match_conditions do |digit|
            return match_rule.reference_id
          end

        end

        timeout do
          run_chain(action.timeout_rule.reference_id)
        end

        invalid do
          run_chain(action.invalid_rule.reference_id)
        end

        failure do
          # run_chain(action.failure_rule.reference_id)
          return action.failure_rule.reference_id
        end
      end

      return 0
    end

    def play(action)
      @call_controller.play *action.options[:sound]
      return action.next_action_id
    end

    def record(action)
      @call_controller.record action.options
      return action.next_action_id
    end

    def hangup(action)
      @call_controller.hangup
      return 0
    end

  end
end
