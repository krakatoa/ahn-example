module Ivrzer
  class HangupAction < Ivrzer::Action
    def self.dummy
      Ivrzer::HangupAction.new({:kind => :hangup})
    end
  end
end
