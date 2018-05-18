# encoding: utf-8
require 'acceptance_helper'

describe 'basisc3 WiceGrid', type: :request, js: true do
  before :each do
    visit '/numeric_filters'
  end

  include_examples 'ID filtering, range'
end
