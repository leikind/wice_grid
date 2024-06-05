# encoding: utf-8
require 'acceptance_helper'

describe 'with :include in :initialize_grid to include associated tables WiceGrid', type: :request, js: true do
  before :each do
    visit '/joining_tables'
  end

  it 'has filters for joined tables' do
    expect(page).to have_field('grid[f][priorities.name]')
    expect(page).to have_field('grid[f][statuses.name]')
    expect(page).to have_field('grid[f][projects.name]')
    expect(page).to have_field('grid[f][users.name]')
  end

  it 'allows to filter based on joined tables' do
     fill_in('grid_f_priorities_name', with: 'Normal')
     fill_in('grid_f_statuses_name', with: 'Postponed')
     fill_in('grid_f_projects_name', with: 'Super')
     fill_in('grid_f_users_name', with: 'Koobus')

     find(:css, '#grid_submit_grid_icon').click

     within '.pagination_status' do
       expect(page).to have_content('1-1 / 1')
     end

     within first(:css, 'div.wice-grid-container table.wice-grid tbody tr:first-child td.active-filter') do
       expect(page).to have_content('Normal')
     end

     within first(:css, 'div.wice-grid-container table.wice-grid tbody tr:first-child td') do
       expect(page).to have_content('508')
     end

     within 'div.wice-grid-container table.wice-grid tbody' do
       expect(page).to have_content('sequi')
     end
  end
end
