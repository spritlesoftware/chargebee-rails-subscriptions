module ChargebeeRails
  class EventHandler
    def initialize(event)
      @event = event
    end

    def handle_event
      send(@event.event_type)      
    end

    def subscription_created
      p "I was called from the gem"
    end
  end
end
