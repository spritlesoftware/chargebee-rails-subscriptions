require 'chargebee_rails/sync_plans'

namespace :chargebee_rails do
  #include ChargebeeRails#

  desc "chargebee plans sync with application"
  task :sync_plans => :environment do
    # Prompt user input to get confirmation of the plan sync
    begin
      STDOUT.puts "\n This will sync plans in your application with chargebee, do you want to continue ? [y/n]"
      input = STDIN.gets.strip.downcase
    end until %w(y n).include?(input)
    if input == "y"
      ChargebeeRails::SyncPlans.sync
    else
      STDOUT.puts "Plan sync aborted!"
    end
  end

end
