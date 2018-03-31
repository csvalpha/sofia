require 'simplecov'

SimpleCov.start 'rails' do
  add_filter 'app/controllers/'
  add_filter 'app/jobs/'
  add_filter 'app/mailers/'
  add_filter 'app/policies/'
  add_filter 'app/views/'
  add_filter 'lib/'

  minimum_coverage 95
  minimum_coverage_by_file 95
end

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.allow_message_expectations_on_nil = false
    mocks.verify_partial_doubles = true
  end

  config.order = :random
  Kernel.srand config.seed
end
