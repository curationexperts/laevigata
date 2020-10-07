# frozen_string_literal: true
require 'byebug'
require 'capybara/rspec'
require 'openssl'
require 'selenium/webdriver'

ENV['RAILS_ENV'] ||= 'test'

Dir["#{File.expand_path(__dir__)}/support/**/*.rb"].each { |f| require f }

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end
  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end
  config.shared_context_metadata_behavior = :apply_to_host_groups
  config.filter_run_excluding deployed: true unless ENV['YUL_DC_SERVER']
end
