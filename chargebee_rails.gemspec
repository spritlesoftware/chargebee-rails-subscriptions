# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'chargebee_rails/version'

Gem::Specification.new do |spec|
  spec.name          = "chargebee_rails"
  spec.version       = ChargebeeRails::VERSION
  spec.authors       = ["Chargebee"]
  spec.email         = ["info@chargebee.com"]

  spec.summary       = %q{A chargebee subscription management integration gem.}
  spec.description   = %q{This gem provides developers with the ability to easily
                        integrate chargebee's subscription management into their
                        application backed by active record models.}
  spec.homepage      = ""
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org by setting 'allowed_push_host', or
  # delete this section to allow pushing this gem to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = ""
  else
    raise "RubyGems 2.0 or newer is required to protect against public gem pushes."
  end

  spec.files         = Dir["{app,config,lib}/**/*"] + ["Rakefile", "README.md"]
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  # spec.require_paths = ["lib"]

  spec.add_dependency "chargebee", "~> 1.7", ">= 1.7.1"

  spec.add_development_dependency "rails", ">= 3.1"
  spec.add_development_dependency "bundler", "~> 1.10"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.3.0"
  spec.add_development_dependency "webmock"
  spec.add_development_dependency "mocha"
  spec.add_development_dependency "vcr"
  spec.add_development_dependency "pry"
end
