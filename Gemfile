source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '5.1.7'
# Use sqlite3 as the database for Active Record
gem 'sqlite3', '~> 1.3.6'
# Use Puma as the app server
gem 'puma', '3.11.0'
# Use SCSS for stylesheets
gem 'sassc-rails'
# Use HAML for views
gem "haml-rails", "~> 2.0"
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.5'
# Collection of instance types
gem 'cloud-instancetype'
# Bootstrap web framework
gem 'bootstrap', '~> 4.3.1'
gem 'jquery-rails'
# identify 'active' links
gem 'active_link_to'
# Ace editor
gem 'ace-rails-ap'
# HCL parser
gem 'hcl-checker', '~> 1.2'

source 'https://rails-assets.org' do

end

group :development, :test do
  # BDD with rspec
  gem 'rspec-rails', '~> 3.9'
  # fixture DSL
  gem 'factory_bot_rails'
  # fake data
  gem 'faker', git: 'https://github.com/faker-ruby/faker.git', branch: 'master'
  # report test coverage
  gem 'codecov', require: false
  gem 'simplecov', require: false
  # Shim to load environment variables from .env into ENV
  gem 'dotenv-rails'
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  # Adds support for Capybara system testing and selenium driver
  gem 'capybara', '>= 2.15'
  gem 'selenium-webdriver'
  # code style enforcement
  gem 'rubocop', '~> 0.76.0', require: false
  gem 'rubocop-rails'
  gem 'rubocop-rspec'
end

group :development do
  # Access an IRB console on exception pages or by using <%= console %> anywhere in the code.
  gem 'listen', '>= 3.0.5', '< 3.2'
  gem 'web-console', '>= 3.3.0'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
  # Minimal ExecJS backend
  gem 'mini_racer'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
