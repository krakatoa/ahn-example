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
        
        # puts ""
        next_action_id = execute(current_action)

        puts "NEXT_ACTION_ID: #{next_action_id}"
        
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
          case match_rule.conditions[:type]
            when "digit"
              match match_rule.conditions[:digit] do |digit|
                return match_rule.reference_id
              end
            when "range"
              match match_rule.conditions[:from]..match_rule.conditions[:to] do
                return match_rule.reference_id
              end
          end
        end
      end

      return 0
    end

    def play(action)
      puts "play: #{action.inspect}"
      return action.next_action.reference_id rescue nil
    end

    def record(action)
      puts "record: #{action.inspect}"
      return action.next_action.reference_id rescue nil
    end

    def hangup(action)
      puts "hangup: #{action.inspect}"
      return 0
    end

  end
end
