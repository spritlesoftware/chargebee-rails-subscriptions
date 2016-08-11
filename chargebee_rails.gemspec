# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'chargebee_rails/version'

Gem::Specification.new do |spec|
  spec.name          = "chargebee_rails"
  spec.version       = ChargebeeRails::VERSION
  spec.authors       = ["Chargebee", "Spritle"]
  spec.email         = ["chargebee@spritle.com"]

  spec.summary       = %q{A subscription management gem for Rails with ChargeBee.}
  spec.description   = %q{This gem provides developers with the ability to easily
                        integrate chargebee's subscription management into their
                        application backed by active record models.}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = Dir["{app,config,lib}/**/*"] + ["Rakefile", "README.md"]
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  # spec.require_paths = ["lib"]

  spec.add_dependency "chargebee", '~> 2.0', '>= 2.0.5'

  spec.add_development_dependency "rails", ">= 3.1"
  spec.add_development_dependency "bundler", "~> 1.10"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.3.0"
  spec.add_development_dependency "webmock"
  spec.add_development_dependency "mocha"
  spec.add_development_dependency "vcr"
  spec.add_development_dependency "pry"
end
