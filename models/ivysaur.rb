require '../models/ivysaur/action.rb'
require '../models/ivysaur/ivr.rb'
require '../models/ivysaur/menu.rb'
require '../models/ivysaur/match.rb'
require '../models/ivysaur/play.rb'
require '../models/ivysaur/logger.rb'

module Ivysaur
  def self.testing

    {
      :attributes => {},
      :actions =>  [
        { :menu =>  {
                    :attributes => { :timeout => 8 },
                    :actions    => [
                      #{ :play => { :attributes => { :sound => ["/home/krakatoa/mario3.wav"] } } },
                      {
                        :match => { :attributes => { :from => 1, :to => 5 },
                                    :actions => [
                                      {
                                        :logger => { :attributes => { :data => "Se ingreso el digito: ${lambda_match}." },
                                                      :actions => []
                                        }
                                      }
                                    ]
                        }
                      }#,
                      #{
                      #  :menu => {  :attributes => { :timeout => 9 },
                      #              :actions => { }
                      #  }
                      #}
                    ]
          }
        }
      ]
    }
  end

end
