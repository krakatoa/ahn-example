module Ivrzer
  class PlayAction < Ivrzer::Action
    def next_action
      @rules.select { |rule| rule.kind == :next }[0] || Ivrzer::HangupAction.dummy
    end
  end
end
