# frozen_string_literal: true

unless Rails.env.production?
  APP_ROOT = File.dirname(__FILE__)
  require "solr_wrapper"
  require "fcrepo_wrapper"
  require 'solr_wrapper/rake_task'
  require 'resolv-replace'

  desc "Run Continuous Integration"
  task :ci, [:test_suite] do |task, args|
    test_suite = args[:test_suite] || "spec"
    check_style if test_suite == "style"
    ci_with_infrastructure(test_suite) unless test_suite == "style"
  end

  def ci_with_infrastructure(test_suite)
    ENV["environment"] = "test"
    solr_params = {
      port: 8985,
      verbose: true,
      managed: true
    }
    fcrepo_params = {
      port: 8986,
      verbose: true,
      managed: true,
      enable_jms: false,
      fcrepo_home_dir: 'tmp/fcrepo4-test-data'
    }
    SolrWrapper.wrap(solr_params) do |solr|
      solr.with_collection(
        name: "hydra-test",
        persist: false,
        dir: Rails.root.join("solr", "config")
      ) do
        FcrepoWrapper.wrap(fcrepo_params) do
          Rake::Task[test_suite].invoke
        end
      end
    end
    # Rake::Task["doc"].invoke
  end

  RSpec::Core::RakeTask.new(:integration) do |t|
    t.rspec_opts = "--tag integration --profile"
  end

  RSpec::Core::RakeTask.new(:unit) do |t|
    t.rspec_opts = "--tag ~integration --profile"
  end

  desc "Run js tests"
  task :js do
    sh "yarn test"
  end

  def check_style
    sh "bundle exec rubocop"
  end
end
