require 'simplecov'

SimpleCov.start 'rails' do
  filter 'app/controllers/*'
  filter 'app/jobs/*'
  filter 'app/mailers/*'
  filter 'app/policies/*'
  filter 'app/views/*'
  filter 'lib/*'

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
