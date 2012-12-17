# encoding: utf-8

require '../models/ivrzer.rb'

class IvrTesting < Adhearsion::CallController
  def run
    answer

    # call.to
    # => "5588@10.0.0.5"

    ivr = Ivrzer::Ivr.example
    runner = Ivrzer::Runner.new(ivr, self)
    runner.run!

    # record_result = record :max_duration => 60_000
    # logger.info "Recording saved to #{record_result.recording_uri}"

  end

end
