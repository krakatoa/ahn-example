# encoding: utf-8

require '../models/ivysaur'
require '../models/renderers/adhearsion_renderer'

class IvrTesting < Adhearsion::CallController
  def run
    answer

    ivr = Ivysaur::Ivr.new(Ivysaur::testing)
    ivr.renderer = AdhearsionRenderer.new(self)
    ivr.output

    #logger.info "methods: #{self.methods.sort}"

=begin
    record_result = record :max_duration => 60_000
    logger.info "Recording saved to #{record_result.recording_uri}"

    hash_a = { "menu" =>
      { "timeout" => 8,
        "lambda" => "dialed",
        "matches" => { "1-7" => ["play"], "8-9" => ["hangup"] }
      }
    }
    hash_b = { "menu" =>
      { "timeout" => 8,
        "lambda" => "dialed",
        "matches" => { "1-6" => ["play"], "7-9" => ["hangup"] }
      }
    }

    hash = nil
    case rand(2)
      when 0
        hash = hash_a
      when 1
        hash = hash_b
    end

    hash.each_pair do |key, value|
      case key
        when "menu"
          options = value.reject{|k, v| ["lambda", "matches"].include?(k)}.symbolize_keys
          options.symbolize_keys!
          options[:timeout] = options[:timeout].to_i.seconds
          menu options do
            value["matches"].each_pair {|k, v|
              from, to = k.split("-")
              to ||= from
              from = from.to_i if from
              to = to.to_i if to
              logger.info "from #{from} to #{to}"
                
              match from..to do |lamb|
                logger.info "matched: #{lamb} value: #{v}"
                v.each do |action|
                  case action
                    when "play"
                      logger.info "Play: #{lamb}"
                      hangup
                    when "hangup"
                      logger.info "Hangup!"
                      hangup
                  end
                end
              end
            }

            timeout {
              logger.info "Testing timeout"
              hangup
            }
          end
      end
    end

=end
  end

end
