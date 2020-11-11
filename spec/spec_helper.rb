
require 'simplecov'
SimpleCov.start


$: << File.expand_path("../lib")
require "checked_record"
PROJECT_ROOT = File.expand_path "../..", __FILE__
Dir[File.join(PROJECT_ROOT,"spec/support/**/*.rb")].each {|f| require f}

RSpec.configure do |c|
  c.filter_run wip: true
  c.run_all_when_everything_filtered = true

  if c.files_to_run.one?
    # Use the documentation formatter for detailed output,
    # unless a formatter has already been configured
    # (e.g. via a command-line flag).
    c.default_formatter = "doc"
  end

end

