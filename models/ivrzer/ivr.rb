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

      @variables = {}
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
            :options => { :sounds => ["/home/krakatoa/mario3.wav"], :tries=> 3, :timeout => 5 },
            #:options => { :tries=> 3, :timeout => 5 },
            :rules => [
              {
                :kind => :match,
                :conditions => { :digit => 2, :type => "digit" },
                :reference_id => 2 # mario + 1up
              },
              {
                :kind => :match,
                :conditions => { :digit => 3, :type => "digit" },
                :reference_id => 3 # 1up
              },
              {
                :kind => :match,
                :conditions => { :digit => 7, :type => "digit"},
                :reference_id => 7
              },
              {
                :kind => :timeout,
                :reference_id => 4 # luigi
              },
              {
                :kind => :invalid,
                :reference_id => 4 # luigi
              },
              {
                :kind => :failure,
                :reference_id => 5 # luigi + record
              },
              {
                :kind => :match,
                :conditions => { :pattern => "99*", :type => "pattern" },
                :reference_id => 99
              }
            ]
          },
          {
            :id => 2,
            :kind => :play,
            :options => {
              :sounds => ["/home/krakatoa/mario3.wav"]
            },
            :rules => [
            {
              :kind => :next,
              :reference_id => 3             }
            ]
          },
          {
            :id => 3,
            :kind => :play,
            :options => {
              :sounds => ["/home/krakatoa/1up.wav"]
            },
            :rules => [
            #{
            #  :kind => :next,
            #  :reference_id => 2 }
            ]
          },
          {
            :id => 4,
            :kind => :play,
            :options => {
              :sounds => ["/home/krakatoa/luigi.wav"]
            },
            :rules => [
            #{
            #  :kind => :next,
            #  :reference_id => 5
            #}
            ]
          },
          {
            :id => 5,
            :kind => :play,
            :options => {
              :sounds => ["/home/krakatoa/1up.wav"]
            },
            :rules => [
            {
              :kind => :next,
              :reference_id => 6
            }
            ]
          },
          {
            :id => 6,
            :kind => :record,
            :options => { :max_duration => 30, :interruptible => false },
            :rules => [
              { :kind => :next,
                :reference_id => 3
              }
            ]
          },
          {
            :id => 7,
            :kind => :dial,
            :options => {
              :destinations => ["user/1001"]
              #:destinations => ["sofia/internal/1001@10.0.0.5:5060"]
            },
            :rules => [
            {:kind => :next, :reference_id => 5}
            ],
          },
          {
            :id => 99,
            :kind => :hangup,
            :options => {},
            :rules => []
          }
        ]
      }
      Ivrzer::Ivr.new(hash)
    end

  end
end
