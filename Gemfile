source 'https://rubygems.org'

ruby '~> 2.4'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?('/')
  "https://github.com/#{repo_name}.git"
end

gem 'bcrypt', '>= 3.1.12'
gem "bootstrap-sass", ">= 3.4.1"
gem 'clamby', '>= 1.2.5'
# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails'
gem 'darlingtonia', github: 'curationexperts/darlingtonia', branch: 'master'
gem 'devise'
gem 'devise-guests', '~> 0.5'
gem 'dotenv-rails'
gem 'factory_bot_rails' # Needed so we can load fixtures for demos in production
gem 'ffaker' # Needed so we can load fixtures for demos in production
gem 'honeybadger'
gem 'hydra-role-management'
gem 'hyrax', '~> 2.8'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder'
# Use jquery as the JavaScript library
gem 'jquery-rails'
# mail pinned to specific version to address "SMTP INJECTION VIA TO/FROM ADDRESSES" vulnerability
# See https://gemnasium.com/gems/mail
gem 'loofah', '~> 2.3'
gem 'mail', '2.6.6.rc1'
gem 'net-sftp'
gem 'nokogiri', '>= 1.10.4'
gem 'okcomputer'
gem 'omniauth-shibboleth', '~> 1.2', '>= 1.2.1'
gem 'pg', '~> 1.0'
gem 'rack', '>= 2.1.4'
gem 'rails'
gem 'rsolr', '~> 1.0'
gem 'rubyzip'
gem 'sanitize', '~> 5.2'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'
gem 'sidekiq'
gem 'tinymce-rails'
# Turbolinks makes navigating your web application faster. Read more: https://github.com/turbolinks/turbolinks
gem 'turbolinks', '~> 5'
gem 'twitter-bootstrap-rails'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
gem 'webpacker', '~> 4'
gem 'whenever', require: false
gem 'xray-rails'
gem 'yard'

group :development, :test do
  gem 'bixby'
  gem 'byebug', platform: :mri
  gem 'capybara'
  gem 'capybara-screenshot'
  gem 'coveralls', require: false
  gem 'database_cleaner'
  gem 'fcrepo_wrapper'
  gem 'hyrax-spec'
  gem 'jasmine' # Needed for testing forms
  gem 'launchy'
  gem 'rails-controller-testing'
  gem 'rspec', "~> 3.5"
  gem 'rspec-activemodel-mocks'
  gem 'rspec-its'
  gem 'rspec-rails', "~> 3.5"
  gem 'rspec_junit_formatter'
  gem 'selenium-webdriver'
  gem 'shoulda-matchers'
  gem 'solr_wrapper', '>= 0.3'
  gem 'vcr'
  gem 'webdrivers'
  gem 'webmock', '~> 3.3'
end

group :development do
  gem 'capistrano'
  gem 'capistrano-bundler'
  gem 'capistrano-passenger'
  gem 'capistrano-rails'
  gem 'capistrano-sidekiq', '~> 0.20.0'
  gem 'listen', '~> 3.0.5'
  gem 'pry'
  gem 'pry-byebug'
  # Spring speeds up development by keeping your application running in the
  # background. Read more: https://github.com/rails/spring
  gem 'puma'
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
  # Access an IRB console on exception pages or by using <%= console %> anywhere
  # in the code.
  gem 'web-console', '>= 3.3.0'
end

extra_gems = "/opt/laevigata/shared/Gemfile.local"
eval File.read(extra_gems) if File.exist?(extra_gems) # rubocop:disable Security/Eval
