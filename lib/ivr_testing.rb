# encoding: utf-8

class IvrTesting < Adhearsion::CallController
  def run
    answer

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
                
                #from = 1
                #to = 7
                #match from..to do |lamb|
                #  logger.info "Play: #{lamb}"
                #  hangup
                #end
                #
                #from = 8
                #to = 9
                #match from..to do
                #  logger.info "Hangup!"
                #  hangup
                #end
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

    #        timeout {
    #          logger.info "Testing timeout"
    #          hangup
    #        }
          end
      end
    end

    #menu :timeout => 8.seconds do
    #  match 1..8 do |dialed|
    #    logger.info dialed
    #  end
    #
    #  match 9 do
    #    hangup
    #  end

    #  timeout {
    #    logger.info "test"
    #    hangup
    #  }

    #end
  end

end
