require 'chargebee_rails/webhook_handler'

namespace :chargebee_rails do
  include ChargebeeRails::WebhookHandler
  
  desc "Sync Failed Events"
  task sync_failed_events: :environment do
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

  def retrieve_failed_events
    options[:start_time] = events_last_synced_at.to_i
    options[:offset] = @offset if @offset.present?
    ChargeBee::Event.list(options)
  end

  def sync_failed_events
    failed_events.each do |chargebee_event|
      handle(chargebee_event)
    end
  end

  def options
    @options ||= {
      limit: 100,
      webhook_status: 'failed',
      end_time: Time.now.to_i
    }
  end

  def events_last_synced_at
    select_query = "SELECT * FROM event_sync_logs;"
    chargebee_rails_records = ActiveRecord::Base.connection.execute(select_query)
    Time.parse(chargebee_rails_records.first['updated_at']) if chargebee_rails_records.first.present?
  end

  def update_event_synced_at
    events_last_synced_at.present? ? update_record : insert_new_record
  end

  def update_record
    update_query = "UPDATE event_sync_logs SET updated_at='#{Time.now}' WHERE id=1 ;"
    ActiveRecord::Base.connection.execute(update_query)
  end

  def insert_new_record
    insert_query = "INSERT INTO event_sync_logs (id, created_at, updated_at) VALUES (1, '#{Time.now}', '#{Time.now}');"
    ActiveRecord::Base.connection.execute(insert_query)
  end

end
