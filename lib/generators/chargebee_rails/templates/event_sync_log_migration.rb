class CreateEventSyncLog < ActiveRecord::Migration
  def change
    create_table :event_sync_logs do |t|

      t.timestamps null: false
    end
  end
end
