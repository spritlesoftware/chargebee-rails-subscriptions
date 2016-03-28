# ChargebeeRails

Welcome to your new gem! In this directory, you'll find the files you need to be able to package up your Ruby library into a gem. Put your Ruby code in the file `lib/chargebee_rails`. To experiment with that code, run `bin/console` for an interactive prompt.

TODO: Delete this and the text above, and describe your gem

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'chargebee_rails'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install chargebee_rails

## Usage

Add subscription models to your app

    $ rails g chargebee_rails:install <subscription_owner_model>

(Note: Allow migration to override templates)

Migrate the changes

    $ rake db:migrate

Setup a Plan locally from your chargebee account

```ruby
Plan.create(name: "CB Demo Hustle", plan_id: "cbdemo_hustle", price: 49, period: 1, period_unit: "month", status: "active")
```
Configure the app for setting a default plan for you application

```ruby
# config/initializers/chargebee_rails.rb
    
ChargebeeRails.configure do |config|
    config.default_plan_id = '<your_plan_in_chargebee>'
end
```
## Development

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/chargebee_rails. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

