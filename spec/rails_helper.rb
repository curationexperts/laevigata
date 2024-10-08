# frozen_string_literal: true

if ENV['COVERAGE'] == 'true'
  require 'simplecov'
  require 'simplecov-lcov'
  SimpleCov::Formatter::LcovFormatter.config.report_with_single_file = true
  SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter.new([
                                                                   SimpleCov::Formatter::HTMLFormatter,
                                                                   SimpleCov::Formatter::LcovFormatter
                                                                 ])

  SimpleCov.start do
    # Can filter out files from coverage reports, example below.
    # add_filter 'app/controllers/metadata_samples_controller.rb'
    add_filter "/app/javascript/test/"
    add_filter "/test/"
    add_filter "/spec/"
    add_filter "README"
  end
end

# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
# Prevent database truncation if the environment is production
abort("The Rails environment is running in production mode!") if Rails.env.production?
require 'spec_helper'
require 'rspec/rails'
require 'devise'
require 'devise/version'
require 'rspec/its'
require 'rspec/matchers'
require 'rspec/active_model/mocks'
require 'active_fedora/cleaner'
require 'capybara/rspec'
require 'capybara/rails'
require 'capybara-screenshot/rspec'
require 'hyrax/spec/factory_bot/build_strategies'
require 'noid/rails/rspec'
require 'ffaker'
require 'webmock/rspec'
require 'vcr'

WebMock.allow_net_connect!(net_http_connect_on_start: true)

VCR.configure do |config|
  config.ignore_hosts '127.0.0.1', 'localhost'
  config.cassette_library_dir = "#{::Rails.root}/spec/fixtures/vcr_cassettes"
  config.hook_into :webmock
  config.allow_http_connections_when_no_cassette = true
end

# Require support files
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }

ActiveRecord::Migration.maintain_test_schema!

# See https://github.com/thoughtbot/shoulda-matchers#rspec
Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :rspec
    with.library :rails
  end
end

RSpec.configure do |config|
  include Noid::Rails::RSpec

  # Set the environment variable `SMOKE_TEST` to run slow running
  # tests that provide additional information about configuration, integration
  # with external services, or other checks that provide useful feedback,
  # but don't impact core coverage
  config.filter_run_excluding(smoke_test: true) unless ENV['SMOKE_TEST']

  config.fixture_path = "#{::Rails.root}/spec/fixtures"
  config.use_transactional_fixtures = true
  config.infer_spec_type_from_file_location!

  config.before :suite do
    disable_production_minter!
    ActiveFedora::Cleaner.clean!

    Hydra::Works.default_system_virus_scanner = TestVirusScanner
  end

  config.after :suite do
    enable_production_minter!
  end

  config.before clean: true do
    ActiveFedora::Cleaner.clean!
  end

  # config.after clean: true do
  #   ActiveFedora::Cleaner.clean!
  # end

  config.before perform_jobs: true do
    ActiveJob::Base.queue_adapter.perform_enqueued_jobs = true
  end

  config.after perform_jobs: true do
    ActiveJob::Base.queue_adapter.filter                = nil
    ActiveJob::Base.queue_adapter.perform_enqueued_jobs = false
  end

  config.before(:example, :workflow) do |example|
    ActiveFedora::Cleaner.clean!

    workflow_settings = example.metadata[:workflow].try(:to_h) || {}
    workflow_settings = { superusers_config: "#{fixture_path}/config/emory/superusers.yml",
                          admin_sets_config: "#{fixture_path}/config/emory/ec_admin_sets.yml",
                          log_location:      "/dev/null" }.merge(workflow_settings)

    setup_args = [workflow_settings[:superusers_config],
                  workflow_settings[:admin_sets_config],
                  workflow_settings[:log_location]]

    WorkflowSetup.new(*setup_args).setup
  end

  # config.after(:example, :workflow) do |example|
  #   ActiveFedora::Cleaner.clean!
  # end

  config.include Devise::Test::ControllerHelpers, type: :controller
  config.include Devise::Test::IntegrationHelpers, type: :request
  config.include Warden::Test::Helpers, type: :system
  config.include Capybara::RSpecMatchers, type: :input

  config.include Warden::Test::Helpers, type: :feature
  config.after(:each, type: :feature) { Warden.test_reset! }

  # Clean up any leftover ActiveStorage blobs from disk (assumes test uses the :disk service)
  config.after :suite do
    active_storage_root = ActiveStorage::Blob.service.root
    FileUtils.rm_rf(active_storage_root)
  end

  # Gets around a bug in RSpec where helper methods that are defined in views aren't
  # getting scoped correctly and RSpec returns "does not implement" errors. So we
  # can disable verify_partial_doubles if a particular test is giving us problems.
  # Ex:
  #   describe "problem test", verify_partial_doubles: false do
  #     ...
  #   end
  config.before do |example|
    config.mock_with :rspec do |mocks|
      mocks.verify_partial_doubles = example.metadata.fetch(:verify_partial_doubles, true)
    end
  end
end
