# encoding: utf-8
require 'acceptance_helper'

describe 'custom_ordering WiceGrid', type: :request, js: true do
  before :each do
    visit '/custom_filters3'
  end

  it 'should have all options' do
    within '#grid_f_expected_version_id' do
      page.should have_content('1.0')
      page.should have_content('2.0')
      page.should have_content('1.2')
    end

    within '#grid_f_versions_name' do
      page.should have_content('1.0')
      page.should have_content('1.1')
      page.should have_content('1.2')
      page.should have_content('2.0')
      page.should have_content('3.0')
      page.should have_content('6.0')
      page.should have_content('7.1')
      page.should have_content('8.0')
      page.should have_content('88.1')
      page.should have_content('99.0')
    end
  end

  it 'should filter by custom fields' do
    first(:css, '.expand-multi-select-icon').click

    select('1.0', from: 'grid_f_versions_name')
    select('1.1', from: 'grid_f_versions_name')

    find(:css, '#grid_submit_grid_icon').click

    within '.pagination_status' do
      page.should have_content('1-5 / 5')
    end

    select '1.0', from: 'grid_f_expected_version_id'

    find(:css, '#grid_submit_grid_icon').click

    within '.pagination_status' do
      page.should have_content('1-2 / 2')
    end
  end
end
