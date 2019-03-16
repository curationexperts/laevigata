# frozen_string_literal: true
unless Rails.env.production?
  require 'solr_wrapper/rake_task'

  # Split the test suite into two parts: unit tests and integration tests
  # Integration tests take longer to run individually, but there are fewer
  # of them so the suite as a whole takes less time than unit tests.
  # Bundle integration with style checking and javascript tests (both relatively
  # quick) to create a balanced job.
  desc "Run Continuous Integration"
  task :ci, [:test_suite] do |task, args|
    test_suite = args[:test_suite] || "integration"
    Rake::Task['unit_ci'].invoke if test_suite == "unit"
    Rake::Task['integration_ci'].invoke if test_suite == "integration"
  end

  desc "Run integration CI"
  task :integration_ci do
    with_server 'test' do
      Rake::Task['db:create'].invoke
      Rake::Task['db:migrate'].invoke
      Rake::Task['webpacker:compile'].invoke
      Rake::Task['rubocop'].invoke
      Rake::Task['integration'].invoke
    end
  end

  desc "Run unit CI"
  task :unit_ci do
    with_server 'test' do
      Rake::Task['db:create'].invoke
      Rake::Task['db:migrate'].invoke
      Rake::Task['webpacker:compile'].invoke
      # These are js unit tests
      Rake::Task['js_ci'].invoke
      Rake::Task['unit'].invoke
    end
  end

  desc "Run javascript CI"
  task :js_ci do
    sh "yarn test"
  end

  RSpec::Core::RakeTask.new(:integration) do |t|
    t.rspec_opts = "--tag integration --profile"
  end

  RSpec::Core::RakeTask.new(:unit) do |t|
    t.rspec_opts = "--tag ~integration --profile"
  end
end
