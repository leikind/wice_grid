# encoding: utf-8
require 'acceptance_helper'

describe 'custom_ordering WiceGrid', type: :feature, js: true do
  before :each do
    visit '/custom_filters3'
  end

  it 'should have all options' do
    expect(page).to have_select('grid_f_expected_version_id', options: %w(-- 1.0 2.0 1.2))
    expect(page).to have_select('grid_f_versions_name', options: %w(-- 1.0 1.1 1.2 2.0 3.0 6.0 7.1 8.0 88.1 99.0))
  end

  it 'should filter by custom fields' do
    first(:css, '.expand-multi-select-icon').click

    select('1.0', from: 'grid_f_versions_name')
    select('1.1', from: 'grid_f_versions_name')

    find(:css, '#grid_submit_grid_icon').click

    within '.pagination_status' do
      expect(page).to have_content('1-5 / 5')
    end

    select '1.0', from: 'grid_f_expected_version_id'

    find(:css, '#grid_submit_grid_icon').click

    within '.pagination_status' do
      expect(page).to have_content('1-2 / 2')
    end
  end
end
