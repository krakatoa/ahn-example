class AdhearsionRenderer
  def initialize(call_controller)
    @call_controller = call_controller
  end

  def ivr(attributes, actions, additionals={})
    renderer = self
    actions.each do |action|
      renderer.send(action.kind, action.attributes, action.actions, additionals)
      #action.output({:renderer => renderer})
    end
  end

  def menu(attributes, actions, additionals={})
    renderer = self
    attributes[:timeout] = attributes[:timeout].to_i.seconds
    @call_controller.menu attributes do
      current_menu = self
      @call_controller.logger.info "This is inside the menu, actions: #{actions.inspect}"
      actions.each do |action|
        renderer.send(action.kind, action.attributes, action.actions, {:current_menu => current_menu})
        #from = action.attributes[:from].to_i
        #to = action.attributes[:to].to_i
        #match from..to do |lamb|
        #  action.actions.each do |subaction|
        #    subaction.output({:renderer => renderer, :lambda_match => lamb})
        #  end
        #end
        # action.output({:renderer => renderer, :current_menu => current_menu})
      end
    end
  end

  def match(attributes, actions, additionals={})
    renderer = self
    current_menu = additionals[:current_menu]
    @call_controller.logger.info "Match actions: #{actions.inspect}"
    @call_controller.logger.info "Match attributes: #{attributes.inspect}"
    @call_controller.logger.info "Match additionals: #{additionals.inspect}"
    from = attributes[:from]
    to = attributes[:to]
    current_menu.match from..to do |digit|
      actions.each do |action|
        # renderer.send(action.kind, action.attributes, {:lambda_match => digit})
        action.output({:renderer => renderer, :lambda_match => digit})
      end
    end
  end

  def logger(attributes, actions, additionals={})
    # todo: ver que no sea necesario cargar el array actions en este logger
    # todo: ver en todos de agregar tanto @renderer, como variables de entorno tipo lambdas, o menues, o call_controller, en un parametro adicional
    lambda_match = additionals[:lambda_match]

    renderer = self
    @call_controller.logger.info "inside logger"
    attributes[:data] = attributes[:data].gsub("$lambda_match", lambda_match) if lambda_match
    @call_controller.logger.info attributes[:data]
  end

  def play(attributes, actions, additionals={})
    @call_controller.play *attributes[:sound]
  end
end

class DebugRenderer
  
  def ivr(attributes, actions)
    puts "<ivr>"
    #puts attributes.inspect
    actions.each do |action|
      action.output(self)
    end
    puts "</ivr>"
  end

  def menu(attributes, actions)
    puts "<menu>"
    puts attributes.inspect
    
    # Adhearsion.menu 
    actions.each do |action|
      action.output(self)
    end

    puts "</menu>"
  end

  def play(attributes, actions)
    puts "<play>"
    puts attributes.inspect
    # puts actions.inspect
    puts "</play>"
  end
end

module Ivysaur
end

class Ivysaur::Action
  @@actions = [:menu, :play, :match, :logger]

  def initialize(ivr, current_scope)
    @ivr = ivr
    @scope = current_scope

    @renderer = nil
  end

  def renderer=(renderer)
    @renderer = renderer
  end

  def scope
    @scope
  end

  def attributes
    @scope[:attributes]
  end

  def output(additionals={})
    renderer = @renderer || additionals[:renderer]
    renderer.send(kind, self.attributes, self.actions, additionals)
  end

  def actions
    return [] if not @scope.has_key?(:actions)
    @scope[:actions].inject([]) { |actions, action_hash|
      key, value = action_hash.keys[0], action_hash.values[0] # should validate that only one pair of key values exist
      actions << Kernel.const_get("Ivysaur").const_get(key.to_s.capitalize).new(@ivr, value) if Ivysaur::Action.actions.include?(key)
      actions
    } 
  end
  
  def self.actions
    @@actions
  end
end

class Ivysaur::Ivr < Ivysaur::Action
  def initialize(hash)
    @ivr = self
    @scope = hash
  end

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
                                        :logger => { :attributes => { :data => "Se ingreso el digito: $lambda_match." },
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

  def menu
    # ivr should contain a single menu
    # actions.select { |action| action.kind == :menu }
  end

  def kind
    :ivr
  end

  #def method_missing(method_name, *args, &block)
  #  Kernel.const_get(method_name.to_s.capitalize).new(self) if Action.actions.include?(method_name)
  #end

end


class Ivysaur::Menu < Ivysaur::Action
  def kind
    :menu
  end
end

class Ivysaur::Match < Ivysaur::Action
  def kind
    :match
  end
end

class Ivysaur::Logger < Ivysaur::Action
  def kind
    :logger
  end
end

class Ivysaur::Play < Ivysaur::Action
  def kind
    :play
  end
end
