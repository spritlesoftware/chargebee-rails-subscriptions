namespace :chargebee_rails do
  # Rake task to setup the necessary tables for subscription
  desc "Install ChargebeeRails"
  task :install do
    system 'rails g chargebee_rails:install'
  end
end
