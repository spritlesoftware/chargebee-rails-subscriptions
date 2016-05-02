namespace :chargebee_rails do

  desc "Install ChargebeeRails"
  task :install do
    system 'rails g chargebee_rails:install'
  end

  desc "chargebee plans sync with application"
  task :sync_plan => :environment do
    begin
      STDOUT.puts "\n This will sync plans in your application with chargebee? [y/n]"
      input = STDIN.gets.strip.downcase
    end until %w(y n).include?(input)
    if input == "y"
      chargebee_plan_list = ChargeBee::Plan.list(limit: 100)
      remove_wrong_plans(chargebee_plan_list)
      create_new_plans(chargebee_plan_list)    
    else
      STDOUT.puts "rake aborted!"
    end
  end

  private

  def remove_wrong_plans(chargebee_plan_list)
    chargebee_plan_ids = chargebee_plan_list.map{ |entry| entry.plan.id }
    Plan.all.each do |plan|
      unless chargebee_plan_ids.include?plan.plan_id
        p plan.plan_id + " deleted..."
        plan.delete
      end
    end    
  end

  def create_new_plans(chargebee_plan_list)
    chargebee_plan_list.each do |entry|
      chargebee_plan = entry.plan
      application_plan = Plan.find_by(plan_id: chargebee_plan.id)
      if application_plan.present?
        p chargebee_plan.name + " is already exist..."
      else
        new_plan = Plan.create({
          name: chargebee_plan.name, 
          plan_id: chargebee_plan.id,
          price: chargebee_plan.price,
          period: chargebee_plan.period,
          period_unit: chargebee_plan.period_unit,
          status: chargebee_plan.status,          
        })
        p new_plan.name + " created..."
      end
    end
  end

end
