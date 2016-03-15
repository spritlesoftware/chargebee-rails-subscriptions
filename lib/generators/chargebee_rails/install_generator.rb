require 'rails/generators'
module ChargebeeRails
  class InstallGenerator < Rails::Generators::Base

    include Rails::Generators::Migration

    argument :subscription_owner_model, :type => :string, :required => true, :desc => "Owner of the subscription"
    desc "ChargebeeRails installation generator"

    def self.source_paths
      [File.expand_path("../templates", __FILE__)]
    end


    # Override subscription_owner_model to ensure it is always returned lowercase.
    def subscription_owner_model
      @subscription_owner_model.downcase
    end

    def install
      # unless defined?(ChargebeeRails)
      #   gem("chargebee_rails")
      # end

      # require "securerandom"
      # template "config/initializers/chargebee.rb"

      # Generate subscription.
      generate("model", "subscription chargebee_id:string chargebee_plan:string status:string plan_id:integer #{subscription_owner_model}_id:integer")
      template "app/models/subscription.rb"

      # Generate plan.
      generate("model", "plan name:string plan_id:string price:decimal status:string")
      template "app/models/plan.rb"

      # Generate card.
      generate("model card cb_customer_id:string last4:string card_type:string status:string subscription_id:integer")
      template "app/models/card.rb"

      # Update the owner relationship and add related_fields.
      generate("migration add_chargebee_id_to_#{subscription_owner_model} chargebee_id:string")
      inject_into_class "app/models/#{subscription_owner_model}.rb", subscription_owner_model.camelize.constantize,
                        "# Added by ChargebeeRails.\n  has_one :subscription\n\n include ChargebeeRails\n\n"
    end
  end
end