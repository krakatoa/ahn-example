module Ivrzer
  class MenuAction < Ivrzer::Action
    def matches
      @rules.select { |rule| rule.kind == :match }
    end

    def timeout_rule
      @rules.select { |rule| rule.kind == :timeout }[0]
    end

    def invalid_rule
      @rules.select { |rule| rule.kind == :invalid }[0]
    end

    def failure_rule
      @rules.select { |rule| rule.kind == :failure }[0]
    end
  end
end
