namespace :chargebee_rails do

  desc "chargebee plans sync with application"
  task :sync_plans => :environment do
    # Prompt user input to get confirmation of the plan sync
    begin
      STDOUT.puts "\n This will sync plans in your application with chargebee, do you want to continue ? [y/n]"
      input = STDIN.gets.strip.downcase
    end until %w(y n).include?(input)
    if input == "y"
      # Keep collecting the plans from chargebee until an offset is not provided
      loop do
        plan_list = retrieve_plan_list
        @offset = plan_list.next_offset
        cb_plans << plan_list.flat_map(&:plan)
        break unless @offset.present?
      end
      @cb_plans = cb_plans.flatten
      sync_plans
    else
      STDOUT.puts "Plan sync aborted!"
    end
  end

  private

  def cb_plans
    @cb_plans ||= []
  end

  def sync_plans
    # puts "Removed #{remove_plans.count} plan(s)"
    puts "Created #{create_new_plans.count} plan(s)"
    # puts "Updated all #{update_all_plans.count} plan(s)"
  end

  # Retrieve the plan list from chargebee
  def retrieve_plan_list
    options = { limit: 100 }
    options[:offset] = @offset if @offset.present?
    ChargeBee::Plan.list(options)
  end

  # Remove plans from application that do not exist in chargebee
  def remove_plans
    cb_plan_ids = cb_plans.flat_map(&:id)
    Plan.all.reject { |plan| cb_plan_ids.include?(plan.plan_id) }
            .each   { |plan| puts "Deleting Plan - #{plan.plan_id}"; plan.destroy }
  end

  # Create new plans that are not present in app but are available in chargebee
  def create_new_plans
    plan_ids = Plan.all.map(&:plan_id)
    cb_plans.reject { |cb_plan| plan_ids.include?(cb_plan.id) }
            .each   { |new_plan| puts "Creating Plan - #{new_plan.id}"; Plan.create(plan_params(new_plan)) }
  end

  # Update all existing plans in the application
  def update_all_plans
    cb_plans.map do |cb_plan|
      Plan.find_by(plan_id: cb_plan.id).update(plan_params(cb_plan))
    end
  end

  # Build the plan params to be created or updated in the application
  def plan_params plan
    {
      name: plan.name,
      plan_id: plan.id,
      status: plan.status,
      chargebee_data: {
        price: plan.price,
        period: plan.period,
        period_unit: plan.period_unit,
        trial_period: plan.trial_period,
        trial_period_unit: plan.trial_period_unit,
        charge_model: plan.charge_model,
        free_quantity: plan.free_quantity
      }
    }
  end
end
