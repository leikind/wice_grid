# encoding: utf-8
require 'acceptance_helper'

describe 'joining_tables WiceGrid', type: :request, js: true do
  before :each do
    visit '/joining_tables'
  end

  it 'should have filters for joined tables' do
    page.should have_field('grid[f][priorities.name]')
    page.should have_field('grid[f][statuses.name]')
    page.should have_field('grid[f][projects.name]')
    page.should have_field('grid[f][users.name]')
  end

  it 'should have filter joined tables' do
     fill_in('grid_f_priorities_name', with: 'Normal')
     fill_in('grid_f_statuses_name', with: 'Postponed')
     fill_in('grid_f_projects_name', with: 'Super')
     fill_in('grid_f_users_name', with: 'Koobus')

     find(:css, '#grid_submit_grid_icon').click

     within '.pagination_status' do
       page.should have_content('1-1 / 1')
     end

     within first(:css, 'div.wice-grid-container table.wice-grid tbody tr:first-child td.active-filter') do
       page.should have_content('Normal')
     end

     within first(:css, 'div.wice-grid-container table.wice-grid tbody tr:first-child td') do
       page.should have_content('508')
     end

     within 'div.wice-grid-container table.wice-grid tbody' do
       page.should have_content('sequi')
     end
  end
end
