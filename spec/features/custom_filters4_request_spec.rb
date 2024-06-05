# encoding: utf-8
require 'acceptance_helper'

describe 'with allow_multiple_selection: false WiceGrid', type: :feature, js: true do
  before :each do
    visit '/custom_filters4'
  end

  it 'does not allow to expand custom filters' do
    expect(page).to have_no_selector('.expand-multi-select-icon')
    expect(page).to have_no_selector('.collapse-multi-select-icon')
  end
end
