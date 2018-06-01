migration_superclass = if ActiveRecord::VERSION::MAJOR >= 5
  ActiveRecord::Migration[4.2]
else
  ActiveRecord::Migration
end

class CreateEventSyncLog < migration_superclass
  def change
    create_table :event_sync_logs do |t|

      t.timestamps null: false
    end
  end
end
