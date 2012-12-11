class AdhearsionRenderer

  def initialize(call_controller)
    @call_controller = call_controller
  end

  def ivr(attributes, actions, env={})
    actions.each do |action|
      action.output
    end
  end

  def menu(attributes, actions, env={})
    attributes[:timeout] = attributes[:timeout].to_i.seconds
    @call_controller.menu attributes do
      current_menu = self
      actions.each do |action|
        action.output({:current_menu => current_menu})
      end
    end
  end

  def match(attributes, actions, env={})
    current_menu = env[:current_menu]
    current_menu.match attributes[:from]..attributes[:to] do |digit|
      actions.each do |action|
        action.output({:lambda_match => digit})
      end
    end
  end

  def logger(attributes, actions, env={})
    # todo: ver que no sea necesario cargar el array actions en este logger
    lambda_match = env[:lambda_match]

    attributes[:data] = attributes[:data].gsub("${lambda_match}", lambda_match) if lambda_match
    @call_controller.logger.info attributes[:data]
  end

  def play(attributes, actions, env={})
    @call_controller.play *attributes[:sound]
  end
end
