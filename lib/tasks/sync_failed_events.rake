require 'chargebee_rails/webhook_handler'

namespace :chargebee_rails do
  include ChargebeeRails::WebhookHandler
  
  desc "Sync Failed Events"
  task sync_failed_events: :environment do
    # Keep collecting the failed events until no offset is present
    loop do
      event_list = retrieve_failed_events
      @offset = event_list.next_offset
      failed_events << event_list.flat_map(&:event)
      break unless @offset.present?
    end
    @failed_events = failed_events.flatten
    puts "Syncing events..."
    sync_failed_events
    update_event_synced_at
  end

  def failed_events
    @failed_events ||= []
  end

  # Retrieve the failed events from chargebee
  def retrieve_failed_events
    options[:start_time] = events_last_synced_at.to_i # Integer timestamp of the last time this rake task ran
    options[:offset] = @offset if @offset.present? # Pass the offset if it is present
    ChargeBee::Event.list(options)
  end

  # Send all the failed events to the ChargebeeRails::WebhookHandler
  def sync_failed_events
    failed_events.each do |chargebee_event|
      handle(chargebee_event)
    end
  end

  # Build the options to retrieve the failed events from chargebee 
  def options
    @options ||= {
      limit: 100,
      webhook_status: 'failed',
      end_time: Time.now.to_i
    }
  end

  # Get the time the rake task was last run
  def events_last_synced_at
    select_query = "SELECT * FROM event_sync_logs;"
    event_sync_logs = ActiveRecord::Base.connection.execute(select_query)
    Time.parse(event_sync_logs.first['updated_at']) if event_sync_logs.first.present?
  end

  # Update the event_sync_logs table with the time once the rake task is completed
  def update_event_synced_at
    events_last_synced_at.present? ? update_record : insert_new_record
  end

  # Set the updated_at column of the existing event_sync_log record
  def update_record
    update_query = "UPDATE event_sync_logs SET updated_at='#{Time.now}' WHERE id=1 ;"
    ActiveRecord::Base.connection.execute(update_query)
  end

  # Create new event_sync_logs record for the first time the rake task is run 
  def insert_new_record
    insert_query = "INSERT INTO event_sync_logs (id, created_at, updated_at) VALUES (1, '#{Time.now}', '#{Time.now}');"
    ActiveRecord::Base.connection.execute(insert_query)
  end

end
