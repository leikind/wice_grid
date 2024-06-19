# encoding: utf-8
require 'acceptance_helper'

describe 'On the page /detached_filters with detached filters WiceGrid', type: :feature, js: true do
  before :each do
    visit '/detached_filters'
  end

  include_examples 'detached_filters'
end
