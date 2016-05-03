require 'rails/generators'
module ChargebeeRails
  class InstallGenerator < Rails::Generators::Base

    include Rails::Generators::Migration

    argument :subscriber_model, :type => :string, :required => true, :desc => "Owner of the subscription"
    desc "ChargebeeRails installation generator"

    def self.source_paths
      [File.expand_path("../templates", __FILE__)]
    end


    # Override subscriber_model to ensure it is always returned lowercase.
    def subscriber_model
      @subscriber_model.downcase
    end

    def install
      # unless defined?(ChargebeeRails)
      #   gem("chargebee_rails")
      # end

      # require "securerandom"
      template "config/initializers/chargebee_rails.rb"

      # Generate subscription.
      generate("model", "subscription chargebee_id:string chargebee_plan:string status:string has_scheduled_changes:boolean plan_id:integer #{subscriber_model}_id:integer plan_quantity:integer trial_ends_at:datetime next_renewal_at:datetime canceled_at:datetime")
      template "app/models/subscription.rb"

      # Generate plan.
      generate("model", "plan name:string plan_id:string price:decimal status:string")
      template "app/models/plan.rb"

      # Generate card.
      generate("model card cb_customer_id:string last4:string card_type:string status:string subscription_id:integer")
      template "app/models/card.rb"

      # Update the owner relationship and add related_fields.
      generate("migration add_chargebee_id_to_#{subscriber_model} chargebee_id:string")
      inject_into_class "app/models/#{subscriber_model}.rb", subscriber_model.camelize.constantize,
                        "# Added by ChargebeeRails.\n  has_one :subscription\n\n include ChargebeeRails::Subscriber\n\n"
    end
  end
end