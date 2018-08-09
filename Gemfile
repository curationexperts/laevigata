source 'https://rubygems.org'

ruby '2.4.2'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?('/')
  "https://github.com/#{repo_name}.git"
end

gem 'bcrypt', '>= 3.1.12'
gem 'clamby', '>= 1.2.5'
# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails'
gem 'darlingtonia', github: 'curationexperts/darlingtonia', branch: 'master'
gem 'devise'
gem 'devise-guests', '~> 0.5'
gem 'dotenv-rails'
gem 'factory_bot_rails' # Needed so we can load fixtures for demos in production
gem 'ffaker' # Needed so we can load fixtures for demos in production
gem 'hydra-role-management'
# gem 'hyrax', '~> 2.1.0'
gem 'hyrax', github: 'samvera/hyrax', branch: 'master'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder'
# Use jquery as the JavaScript library
gem 'jquery-rails'
# mail pinned to specific version to address "SMTP INJECTION VIA TO/FROM ADDRESSES" vulnerability
# See https://gemnasium.com/gems/mail
gem 'loofah', '~> 2.2', '>= 2.2.1'
gem 'mail', '2.6.6.rc1'
gem 'net-sftp'
gem 'nokogiri', '>= 1.8.2'
gem 'okcomputer'
gem 'omniauth-shibboleth', '~> 1.2', '>= 1.2.1'
gem 'pg', '~> 0.21'
# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 5.1'
gem 'rsolr', '~> 1.0'
gem 'rubyzip'
gem 'sanitize', '~> 4.6', '>= 4.6.3'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'
gem 'sidekiq'
# Use sqlite3 as the database for Active Record
gem 'sqlite3'
gem 'tinymce-rails'
# Turbolinks makes navigating your web application faster. Read more: https://github.com/turbolinks/turbolinks
gem 'turbolinks', '~> 5'
gem 'twitter-bootstrap-rails'
# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
gem 'webpacker', '~> 3.5'
gem 'whenever', require: false
gem 'xray-rails'
gem 'yard'

group :production do
  gem 'honeybadger', '~> 3.1'
end

group :development, :test do
  gem 'bixby' # bixby == the hydra community's rubocop rules
  # Call 'byebug' anywhere in the code to stop execution and get a debugger
  # console
  gem 'byebug', platform: :mri
  gem 'capybara'
  gem 'capybara-screenshot'
  gem 'capybara-webkit'
  gem 'coveralls', require: false
  gem 'database_cleaner'
  # gem 'factory_girl_rails'
  gem 'fcrepo_wrapper'
  # gem 'ffaker'
  gem 'hyrax-spec'
  gem 'jasmine' # Needed for testing forms
  gem 'launchy'
  gem 'rails-controller-testing'
  gem 'rspec', "~> 3.5"
  gem 'rspec-activemodel-mocks'
  gem 'rspec-its'
  gem 'rspec-rails', "~> 3.5"
  gem 'shoulda-matchers'
  gem 'solr_wrapper', '>= 0.3'
  gem 'vcr'
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
