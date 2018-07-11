# encoding: utf-8
require 'capybara/rspec'

# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../support/test_app/config/environment', __FILE__)
require 'rspec/rails'
require 'faker'

if ENV['BROWSER']
  Capybara.default_driver = :selenium
else
  require 'capybara/poltergeist'
  Capybara.javascript_driver = :poltergeist

  require 'capybara-screenshot/rspec'
  Capybara::Screenshot.prune_strategy = :keep_last_run
end

# Slow down responses to help debug tests that have race conditions.
if ENV['TEST_RESPONSE_DELAY']
  Capybara.default_wait_time += ENV['TEST_RESPONSE_DELAY'].to_i

  class ActionController::Base
    before_action { sleep ENV['TEST_RESPONSE_DELAY'].to_i }
  end
end

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join('spec/support/**/*.rb')].each { |f| require f }

ALL_TESTS = false

RSpec.configure do |config|
  # config.mock_with :mocha
  # config.mock_with :flexmock
  # config.mock_with :rr

  config.fixture_path = "spec/fixtures"

  config.use_transactional_fixtures = true

  # If true, the base class of anonymous controllers will be inferred
  # automatically. This will be the default behavior in future versions of
  # rspec-rails.
  config.infer_base_class_for_anonymous_controllers = false

  config.global_fixtures = :all

  config.include Capybara::DSL
end

# Disable SQL logging
ActiveRecord::Base.logger = nil

require 'features/shared.rb'
require 'features/shared_detached_filters.rb'
