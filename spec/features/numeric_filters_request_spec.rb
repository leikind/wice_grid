# encoding: utf-8
require 'acceptance_helper'

describe 'On the page /numeric_filters with filter_type: :range WiceGrid', type: :request, js: true do
  before :each do
    visit '/numeric_filters'
  end

  include_examples 'ID filtering, range'
  include_examples 'ID two limits filtering'
end
