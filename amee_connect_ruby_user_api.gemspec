# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'amee_connect_ruby_user_api/version'

Gem::Specification.new do |spec|
  spec.name          = "amee_connect_ruby_user_api"
  spec.version       = AmeeConnectRubyUserApi::VERSION
  spec.authors       = ["Chris Adams"]
  spec.email         = ["wave@chrisadams.me.uk"]
  spec.summary       = %q{A rubygem for administering users on the AMEE connect platform}
  spec.description   = %q{This works by calling specific java classes, to fetch the data to be used for updating users in the database.}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency 'greenletters', '~> 0.3.0'

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "pry"
end
