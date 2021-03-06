# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'lakitu/version'

Gem::Specification.new do |spec|
  spec.name          = "lakitu"
  spec.version       = LakituVersion::VERSION
  spec.authors       = ["Bryan Conrad"]
  spec.email         = ["bkconrad@gmail.com"]
  spec.summary       = %q{Ride the clouds}
  spec.description   = %q{}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~>3.2"
  spec.add_development_dependency "simplecov"

  spec.add_dependency "thor", "~>0.19"
  spec.add_dependency 'aws-sdk-resources', '~> 2'
  spec.add_dependency "iniparse"
end
