require 'rails/all'
require 'rspec/rails'
require 'shoulda/matchers'
require 'support/test_app/config/environment'

ActiveRecord::Migration.maintain_test_schema!

# set up db
# be sure to update the schema if required by doing
# - cd spec/support/rails_app
# - rake db:migrate
ActiveRecord::Schema.verbose = false
load 'support/test_app/db/schema.rb' # db agnostic

require 'spec_helper'
