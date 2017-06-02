source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?('/')
  "https://github.com/#{repo_name}.git"
end

# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~> 4.2'
gem 'devise'
gem 'devise-guests', '~> 0.5'
gem 'hydra-role-management'
gem 'hyrax', '~> 1.0'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.5'
# Use jquery as the JavaScript library
gem 'jquery-rails'
# mail pinned to specific version to address "SMTP INJECTION VIA TO/FROM ADDRESSES" vulnerability
# See https://gemnasium.com/gems/mail
gem 'mail', '2.6.6.rc1'
gem 'pg'
# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 5.0.2'
# use resque-pool for background jobs
# need master from github to get hot-swap functionality
gem 'resque-pool', github: 'nevans/resque-pool'
gem 'resque-web', require: 'resque_web'
gem 'rsolr', '~> 1.0'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'
# Need to constrain the version of Sinatra for resque-web, see https://github.com/sinatra/sinatra/issues/1055
gem 'sinatra', '2.0.0.rc2'
# Use sqlite3 as the database for Active Record
gem 'sqlite3'
gem 'therubyracer'
# Turbolinks makes navigating your web application faster. Read more: https://github.com/turbolinks/turbolinks
gem 'turbolinks', '~> 5'
# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
gem 'yard'

group :development, :test do
  gem 'bixby' # bixby == the hydra community's rubocop rules
  # Call 'byebug' anywhere in the code to stop execution and get a debugger
  # console
  gem 'byebug', platform: :mri
  gem 'capybara'
  gem 'coveralls', require: false
  gem 'database_cleaner'
  gem 'factory_girl_rails'
  gem 'fcrepo_wrapper'
  gem 'launchy'
  gem 'rspec', "~> 3.5"
  gem 'rspec-activemodel-mocks'
  gem 'rspec-its'
  gem 'rspec-rails', "~> 3.5"
  gem 'shoulda-matchers'
  gem 'solr_wrapper', '>= 0.3'
end

group :development do
  gem 'capistrano'
  gem 'capistrano-bundler'
  gem 'capistrano-passenger'
  gem 'capistrano-rails'
  gem 'listen', '~> 3.0.5'
  # Spring speeds up development by keeping your application running in the
  # background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
  # Access an IRB console on exception pages or by using <%= console %> anywhere
  # in the code.
  gem 'web-console', '>= 3.3.0'
end

extra_gems = "/opt/laevigata/shared/Gemfile.local"
eval File.read(extra_gems) if File.exist?(extra_gems) # rubocop:disable Security/Eval
