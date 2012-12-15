module Ivrzer
  class MenuAction < Ivrzer::Action
    def matches
      @rules.select { |rule| rule.kind == :match }
    end
  end
end
