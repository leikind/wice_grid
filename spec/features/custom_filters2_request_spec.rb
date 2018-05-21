# encoding: utf-8
require 'acceptance_helper'

describe 'custom_ordering WiceGrid', type: :request, js: true do
  before :each do
    visit '/custom_filters2'
  end

  it 'should have all options' do
    within '#grid_f_priorities_name' do
      page.should have_content('Anecdotic')
      page.should have_content('High')
      page.should have_content('Low')
      page.should have_content('Normal')
      page.should have_content('Urgent')
    end

    within '#grid_f_status_id' do
      page.should have_content('Assigned')
      page.should have_content('Cancelled')
      page.should have_content('Closed')
      page.should have_content('Duplicate')
      page.should have_content('New')
      page.should have_content('Postponed')
      page.should have_content('Resolved')
      page.should have_content('Started')
      page.should have_content('Verified')
    end

    within '#grid_f_project_id' do
      page.should have_content('Divine Firmware')
      page.should have_content('Super Game')
      page.should have_content('Ultimate Website')
    end
  end

  it 'should filter by custom filters' do
    first(:css, '.expand-multi-select-icon').click

    select('Normal', from: 'grid_f_priorities_name')
    select('Urgent', from: 'grid_f_priorities_name')

    select 'Duplicate', from: 'grid_f_status_id'

    select 'Ultimate Website', from: 'grid_f_project_id'

    find(:css, '#grid_submit_grid_icon').click

    within '.pagination_status' do
      page.should have_content('1-2 / 2')
    end
  end
end
