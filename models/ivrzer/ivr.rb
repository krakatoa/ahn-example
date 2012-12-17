module Ivrzer
  class Ivr
    attr_reader :id
    attr_reader :name
    attr_reader :root_action_id

    def initialize(json)
      @hash = json # in this step, we should deserialize from simple JSON to Ruby hash

      @id = @hash[:id]
      @name = @hash[:name]
      @root_action_id = @hash[:root_action_id]
    end

    def build_action(action_id)
      action_hash = @hash[:actions].select { |action| action[:id] == action_id }[0]
      Ivrzer::Action.build_action(action_hash)
    end

    def to_s
      @id
    end

    def self.example
      hash = { :name => "bla",
        :id => 1,
        :root_action_id => 1,
        :actions => [
          { :id => 1,
            :kind => :menu,
            :options => { :tries=>5, :timeout=>6 },
            :rules => [
              { 
                :kind => :match,
                :conditions => { :from => 1, :to => 3, :type => "range" },
                :reference_id => 2
              },
              {
                :kind => :match,
                :conditions => { :digit => 4, :type => "digit" },
                :reference_id => 4
              },
              {
                :kind => :match,
                :conditions => { :digit => 5, :type => "digit" },
                :reference_id => 5
              },
              {
                :kind => :match,
                :conditions => { :digit => 9, :type => "digit" },
                :reference_id => 3
              }
            ]
          },
          {
            :id => 2,
            :kind => :play,
            :options => {
              :sound => "/home/krakatoa/mario3.wav"
            },
            :rules => []
          },
          {
            :id => 3,
            :kind => :hangup,
            :options => {},
            :rules => []
          },
          { :id => 4,
            :kind => :menu,
            :options => { :tries=>5, :timeout=>6 },
            :rules => [
              { 
                :kind => :match,
                :conditions => { :digit => 1, :type => "digit" },
                :reference_id => 1
              },
              { 
                :kind => :match,
                :conditions => { :digit => 2, :type => "digit" },
                :reference_id => 2
              },
              { 
                :kind => :match,
                :conditions => { :digit => 3, :type => "digit" },
                :reference_id => 3
              }
            ]
          },
          {
            :id => 5,
            :kind => :record,
            :options => { :max_duration => 6 },
            :rules => [
              { :kind => :next,
                :reference_id => 1
              }
            ]
          }
        ]
      }
      Ivrzer::Ivr.new(hash)
    end

  end
end
