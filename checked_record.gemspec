$:.unshift( File.expand_path( "../lib", __FILE__ ) )
require 'checked_record/version'
version = CheckedRecord::VERSION
Gem::Specification.new do |s|
  s.name        = 'checked_record'
  s.version     = version
  s.summary     = 'A Struct like BaseClass on Steroids'
  s.description = %{Allows to define classes with predefined attributes, allowing for defaults, constraints and immutability}
  s.authors     = ["Robert Dober"]
  s.email       = 'robert.dober@gmail.com'
  s.files       = Dir.glob("lib/**/*.rb")
  s.files      += %w{LICENSE README.md}
  s.homepage    = "https://github.com/RobertDober/checked_record"
  s.licenses    = %w{Apache 2}

  s.required_ruby_version = '>= 2.7.0'
  # s.add_dependency 'forwarder2', '~> 0.2'

  s.add_development_dependency 'pry', '~> 0.10'
  s.add_development_dependency 'pry-byebug', '~> 3.9'
  s.add_development_dependency 'rspec', '~> 3.10'
  s.add_development_dependency 'speculate_about', '~> 0.2.1'
  s.add_development_dependency 'travis-lint', '~> 2.0'
end
