class DebugRenderer
  
  def ivr(attributes, actions, env={})
    puts "<ivr>"
    actions.each do |action|
      action.output(self)
    end
    puts "</ivr>"
  end

  def menu(attributes, actions, env={})
    puts "<menu>"
    puts attributes.inspect
    
    actions.each do |action|
      action.output(self)
    end

    puts "</menu>"
  end
  
  def match(attributes, actions, env={})
    puts "<match>"
    puts attributes.inspect
    
    actions.each do |action|
      action.output(self)
    end

    puts "</match>"
  end
  
  def logger(attributes, actions, env={})
    puts "<logger>"
    puts attributes.inspect
    puts env.inspect
    puts "</logger>"
  end

  def play(attributes, actions, env={})
    puts "<play>"
    puts attributes.inspect
    puts "</play>"
  end
end
