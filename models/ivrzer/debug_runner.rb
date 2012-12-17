module Ivrzer
  class Runner
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
      puts "enter a digit:"
      digit = gets.to_i
      action.matches.each do |match|
        case match.conditions[:type]
          when "digit"
            if match.conditions[:digit] == digit
              return match.reference_id
            end
          when "range"
            if digit >= match.conditions[:from] and digit <= match.conditions[:to]
              return match.reference_id
            end
        end
      end
      return 0
    end

    def play(action)
      puts "play: #{action.inspect}"
      return action.next_action_id
    end

    def record(action)
      puts "record: #{action.inspect}"
      return action.next_action_id
    end

    def hangup(action)
      puts "hangup: #{action.inspect}"
      return 0
    end

  end
end
