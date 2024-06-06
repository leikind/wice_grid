require 'rails/all'
require 'spec_helper'
require 'shoulda/matchers'
require 'support/test_app/config/environment'
require 'support/download_helper'
require 'rspec/rails'
require 'selenium-webdriver' if ENV['BROWSER']

ActiveRecord::Migration.maintain_test_schema!

# set up db
# be sure to update the schema if required by doing
# - cd spec/support/rails_app
# - rake db:migrate
ActiveRecord::Schema.verbose = false
load 'support/test_app/db/schema.rb' # db agnostic

RSpec.configure do |config|
  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = true

  # You can uncomment this line to turn off ActiveRecord support entirely.
  # config.use_active_record = false

  # RSpec Rails can automatically mix in different behaviours to your tests
  # based on their file location, for example enabling you to call `get` and
  # `post` in specs under `spec/controllers`.
  #
  # You can disable this behaviour by removing the line below, and instead
  # explicitly tag your specs with their type, e.g.:
  #
  #     RSpec.describe UsersController, type: :controller do
  #       # ...
  #     end
  #
  # The different available types are documented in the features, such as in
  # https://rspec.info/features/6-0/rspec-rails
  config.infer_spec_type_from_file_location!

  # Filter lines from Rails gems in backtraces.
  config.filter_rails_from_backtrace!
  # arbitrary gems may also be filtered via:
  # config.filter_gems_from_backtrace("gem name")
  config.include Shoulda::Matchers::ActiveModel, type: :model
  config.include Shoulda::Matchers::ActiveRecord, type: :model
end

Capybara.register_driver :selenium do |app|
  profile = Selenium::WebDriver::Firefox::Profile.new
  profile['browser.download.dir'] = DownloadHelpers::PATH.to_s
  profile['browser.download.folderList'] = 2

  # Suppress "open with" dialog
  profile['browser.helperApps.neverAsk.saveToDisk'] = 'text/csv'
  profile['browser.startup.homepage'] = 'about:blank' # workaround bug in Selenium 4 alpha4-7
  profile['accessibility.tabfocus'] = 7 # make tab move over links too

  options = Selenium::WebDriver::Firefox::Options.new
  options.profile = profile

  version = Capybara::Selenium::Driver.load_selenium
  options_key = Capybara::Selenium::Driver::CAPS_VERSION.satisfied_by?(version) ? :capabilities : :options
  driver_options = { browser: :firefox, timeout: 31 }.tap do |opts|
    opts[options_key] = options
    # Get a trace level log from geckodriver
    # :driver_opts => { args: ['-vv'] }
  end

  Capybara::Selenium::Driver.new(app, **driver_options)
end
