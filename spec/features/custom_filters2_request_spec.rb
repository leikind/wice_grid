# encoding: utf-8
require 'acceptance_helper'

describe 'custom_ordering WiceGrid', type: :request, js: true do
  before :each do
    visit '/custom_filters2'
  end

  it 'should have all options' do
    within '#grid_f_priorities_name' do
      expect(page).to have_content('Anecdotic')
      expect(page).to have_content('High')
      expect(page).to have_content('Low')
      expect(page).to have_content('Normal')
      expect(page).to have_content('Urgent')
    end

    within '#grid_f_status_id' do
      expect(page).to have_content('Assigned')
      expect(page).to have_content('Cancelled')
      expect(page).to have_content('Closed')
      expect(page).to have_content('Duplicate')
      expect(page).to have_content('New')
      expect(page).to have_content('Postponed')
      expect(page).to have_content('Resolved')
      expect(page).to have_content('Started')
      expect(page).to have_content('Verified')
    end

    within '#grid_f_project_id' do
      expect(page).to have_content('Divine Firmware')
      expect(page).to have_content('Super Game')
      expect(page).to have_content('Ultimate Website')
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
      expect(page).to have_content('1-2 / 2')
    end
  end
end
