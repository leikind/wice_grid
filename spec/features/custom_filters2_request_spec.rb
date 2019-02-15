# encoding: utf-8
require 'acceptance_helper'

describe 'custom_ordering WiceGrid', type: :feature, js: true do
  before :each do
    visit '/custom_filters2'
  end

  it 'should have all options' do
    expect(page).to have_select('grid_f_priorities_name', options: %w(-- Anecdotic High Low Normal Urgent))
    expect(page).to have_select('grid_f_status_id', options: %w(-- Assigned Cancelled Closed Duplicate New Postponed Resolved Started Verified))
    expect(page).to have_select('grid_f_project_id', options: ['--', 'Divine Firmware', 'Super Game', 'Ultimate Website'])
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
