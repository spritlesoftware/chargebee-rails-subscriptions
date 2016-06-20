namespace :chargebee_rails do

  desc "Install ChargebeeRails"
  task :install do
    system 'rails g chargebee_rails:install'
  end
end
