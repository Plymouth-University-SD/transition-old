source 'https://rubygems.org'
source 'https://BnrJb6FZyzspBboNJzYZ@gem.fury.io/govuk/'

gem 'rails', '3.2.13'
gem 'exception_notification', '2.6.1'
gem 'unicorn', '4.6.2'
gem 'mysql2', '0.3.11'
gem 'aws-ses', '0.4.4', require: 'aws/ses'

gem 'plek', '1.2.0'
gem 'gds-sso', '3.0.0'

gem 'therubyracer', '0.11.4'
gem 'jquery-rails', '2.0.2' # TODO: Newer versions break publisher sortable parts. Will need attention.
gem 'jquery-ui-rails', '4.0.3'
gem 'select2-rails', '3.4.3'
gem 'htmlentities', '4.3.1'
gem 'whenever', '0.8.2'
gem 'acts_as_list', '0.2.0'

gem 'activerecord-import', '0.3.1'
gem 'rgarner-csv-mapper', '1.0.0'
gem 'kramdown', '1.1.0'
gem 'optic14n', '1.0.0' # Ideally version should be synced with bouncer

# Gems used only for assets and not required in production
# environments by default.
group :assets do
  gem 'sass', '3.2.8'
  gem 'sass-rails', '3.2.6'
  gem "bootstrap-sass", "2.3.2.1"
  gem 'uglifier', '2.0.1'
end

group :test do
  gem 'capybara', '2.1.0', require: false
  gem 'factory_girl_rails', '4.1.0'
  gem 'ci_reporter', '1.8.0'
  gem 'database_cleaner', '1.0.1'
  gem 'poltergeist', '1.3.0'
  gem 'webmock', '1.11.0', require: false
  gem 'shoulda-matchers', '2.2.0'
  gem 'launchy', '2.3.0'
  gem 'selenium-webdriver', '2.32.1'
end

group :development, :test do
  gem 'rspec-rails', '2.13.2'
  gem 'debugger'
end
