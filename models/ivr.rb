class AdhearsionRenderer
  def initialize(call_controller)
    @call_controller = call_controller
  end

  def ivr(attributes, actions, &block)
    renderer = self
    actions.each do |action|
      action.output(renderer)
    end
  end

  def menu(attributes, actions, &block)
    renderer = self
    attributes[:timeout] = attributes[:timeout].to_i.seconds
    @call_controller.menu attributes do
      current_menu = self
      #@call_controller.logger.info "This is inside a menu: #{self.inspect}"
      actions.each do |action|
        action.output(renderer) { current_menu }
      end
    end
  end

  def match(attributes, actions, &block)
    renderer = self
    current_menu = block.call if block_given?
    #@call_controller.logger.info "Going to render a match block with: #{attributes.inspect} and this menu: #{current_menu}"
    @call_controller.logger.info "actions: #{actions.inspect}"
    current_menu.match 1..4 do |digit|
      @call_controller.logger.info "entered: #{digit}"
    end
    current_menu.timeout {
      @call_controller.logger.info "timeouted"
    }
=begin
    current_menu.match attributes[:from]..attributes[:to] do |digit|
      actions.each do |action|
        action.output(renderer) { digit }
      end
    end
=end
  end

  def logger(attributes, actions, &block)
    # todo: ver que no sea necesario cargar el array actions en este logger
    # todo: ver en todos de agregar tanto @renderer, como variables de entorno tipo lambdas, o menues, o call_controller, en un parametro adicional
    renderer = self
    @call_controller.logger.info "inside logger"
    attributes[:data].gsub!("$lambda_match", block.call) if block_given?
    @call_controller.logger.info attributes[:data]
  end

  def play(attributes, actions, &block)
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

  def output(renderer=nil, &block)
    renderer ||= @renderer
    renderer.send(kind, self.attributes, self.actions, &block)
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
                      { :play => { :attributes => { :sound => ["/home/krakatoa/mario3.wav"] } } },
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
                      },
                      {
                        :menu => {  :attributes => { :timeout => 9 },
                                    :actions => { }
                        }
                      }
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

  #def to_s
  #  render
  #end
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

  #def to_s
  #  render
  #end
end
