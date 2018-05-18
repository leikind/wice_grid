# encoding: utf-8
require 'acceptance_helper'

describe 'custom_filter_params WiceGrid', type: :request, js: true do
  before :each do
    visit '/custom_filter_params'
  end

  it 'should lead to a grid with the project custom filter activated to Ultimate Website' do
    click_on 'Ultimate Website'
    within '.pagination_status' do
      page.should have_content('1-18 / 18')
    end
  end

  it 'should lead to a grid with the project custom filter activated to Super Game' do
    click_on 'Super Game'
    within '.pagination_status' do
      page.should have_content('1-17 / 17')
    end
  end

  it 'should lead to a grid with the project custom filter activated to Divine Firmware' do
    click_on 'Divine Firmware'
    within '.pagination_status' do
      page.should have_content('1-15 / 15')
    end
  end
end
