# This generator is based on rails_admin's install generator.
# https://www.github.com/sferik/rails_admin/master/lib/generators/rails_admin/install_generator.rb

require 'rails/generators'
require 'rails/generators/active_record/migration'

# http://guides.rubyonrails.org/generators.html

module ChargebeeRails
  class InstallGenerator < Rails::Generators::Base

    include Rails::Generators::Migration
    include ActiveRecord::Generators::Migration

    argument :subscriber_model, :type => :string, :required => true, :desc => "Owner of the subscription"
    desc "ChargebeeRails installation generator"

    # The path for the custom migration templates
    def self.source_paths
      [File.expand_path("../templates", __FILE__)]
    end

    # Override subscriber_model to ensure it is always returned lowercase.
    def subscriber_model
      @subscriber_model.downcase
    end

    def install

      # Generate chargebee_rails configuration file template
      template "config/initializers/chargebee_rails.rb"

      # Generate plan.
      generate("model", "plan name:string plan_id:string status:string chargebee_data:text")
      template "app/models/plan.rb", force: true

      # Generate subscription.
      migration_template "new_subscription_migration.rb", "db/migrate/create_subscriptions.rb"
      template "app/models/subscription.rb"

      # Generate payment methods.
      generate("model", "payment_method cb_customer_id:string auto_collection:boolean payment_type:string reference_id:string card_last4:string card_type:string status:string event_last_modified_at:datetime subscription:references")

      # Generate chargebee rails event.
      migration_template "event_sync_log_migration.rb", "db/migrate/create_event_sync_log.rb"

      # Add related fields to the subscription owner table
      generate("migration", "add_chargebee_id_to_#{subscriber_model} chargebee_id:string event_last_modified_at:datetime chargebee_data:text")

      # Specify the relationship between subscription and owner
      inject_into_class "app/models/#{subscriber_model}.rb", subscriber_model.camelize.constantize,
                        "  include ChargebeeRails::Customer\n\n  # Added by ChargebeeRails.\n  has_one :subscription\n  serialize :chargebee_data, JSON\n"
    end
  end
end
