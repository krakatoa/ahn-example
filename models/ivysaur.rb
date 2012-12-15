require_relative './ivysaur/action.rb'
require_relative './ivysaur/ivr.rb'
require_relative './ivysaur/menu.rb'
require_relative './ivysaur/match.rb'
require_relative './ivysaur/play.rb'
require_relative './ivysaur/logger.rb'

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
