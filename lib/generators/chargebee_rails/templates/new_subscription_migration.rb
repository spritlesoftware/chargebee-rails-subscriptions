migration_superclass = if ActiveRecord::VERSION::MAJOR >= 5
  ActiveRecord::Migration[4.2]
else
  ActiveRecord::Migration
end

class CreateSubscriptions < migration_superclass
  def change
    create_table :subscriptions do |t|
      t.string :chargebee_id
      t.references :plan, index: true, foreign_key: true
      t.integer :plan_quantity, default: 1
      t.references :<%= subscriber_model %>, index: true, foreign_key: true
      t.string :status
      t.datetime :event_last_modified_at
      t.text :chargebee_data


      t.timestamps null: false
    end
  end
end
