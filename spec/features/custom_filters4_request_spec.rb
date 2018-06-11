# encoding: utf-8
require 'acceptance_helper'

describe 'custom_ordering WiceGrid', type: :request, js: true do
  before :each do
    visit '/custom_filters4'
  end

  it 'should not be possible to expand custom filters' do
    expect(page).to have_no_selector('.expand-multi-select-icon')
    expect(page).to have_no_selector('.collapse-multi-select-icon')
  end
end
