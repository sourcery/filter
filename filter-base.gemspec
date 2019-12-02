lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
# coding: utf-8
require 'filter/version'

Gem::Specification.new do |spec|
  spec.name          = "filter-base"
  spec.version       = Filter::VERSION
  spec.authors       = ["Ben Bergstein, Jeff Rosen and Nick Chaffee"]
  spec.email         = ["pair+ben+jeff+nick@getsourcery.com"]

  spec.summary       = %q{Easy-to-test filtering for Rails' ActiveRecord}
  spec.description   = %q{Extensions and controller/view helpers for filtering glory}
  spec.homepage      = "https://github.com/sourcery/filter"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "bin"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  if spec.respond_to?(:metadata)
    # spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com' to prevent pushes to rubygems.org, or delete to allow pushes to any server."
  end

  spec.add_development_dependency "bundler", "~> 1.9"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "dotenv"
  spec.add_development_dependency "pg"
  spec.add_development_dependency "sequel"
  spec.add_development_dependency "rspec"

  spec.add_dependency 'rails', '~> 4.2', '>= 4.2'
end
