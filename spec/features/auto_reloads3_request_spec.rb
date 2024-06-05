# encoding: utf-8
require 'acceptance_helper'

describe 'On the page /auto_reloads3 with two tables and detached filters WiceGrid', type: :feature, js: true do
  before :each do
    visit '/auto_reloads3'
  end

  it 'allows to filter grid1 and grid 2 by changing Assigned custom filter independently' do
    select 'yes', :from => 'grid_f_archived'

    within 'div#grid.wice-grid-container .pagination_status' do
      expect(page).to have_content('1-4 / 4')
    end

    within 'div#grid2.wice-grid-container .pagination_status' do
      expect(page).to have_content('1-20 / 50')
    end

    select 'no', :from => 'grid2_f_archived'

    within 'div#grid.wice-grid-container .pagination_status' do
      expect(page).to have_content('1-4 / 4')
    end

    within 'div#grid2.wice-grid-container .pagination_status' do
      expect(page).to have_content('1-20 / 46')
    end
  end

  it 'allows to filter grid1 and grid 2 by changing Status custom filter independently' do
    select 'Assigned', :from => 'grid_f_status_id'

    within 'div#grid.wice-grid-container .pagination_status' do
      expect(page).to have_content('1-4 / 4')
    end

    within 'div#grid2.wice-grid-container .pagination_status' do
      expect(page).to have_content('1-20 / 50')
    end

    select 'Cancelled', :from => 'grid2_f_status_id'

    within 'div#grid.wice-grid-container .pagination_status' do
      expect(page).to have_content('1-4 / 4')
    end

    within 'div#grid2.wice-grid-container .pagination_status' do
      expect(page).to have_content('1-8 / 8')
    end

  end

  it 'allows to filter grid1 and grid 2 by changing Title custom filter independently' do
    fill_in('grid_f_title_v', :with => 'sed')

    within 'div#grid.wice-grid-container .pagination_status' do
      expect(page).to have_content('1-1 / 1')
    end

    fill_in('grid2_f_title_v', :with => 'a')

    within 'div#grid.wice-grid-container .pagination_status' do
      expect(page).to have_content('1-1 / 1')
    end

    within 'div#grid2.wice-grid-container .pagination_status' do
      expect(page).to have_content('1-20 / 31')
    end

  end

  it 'allows to filter grid1 and grid 2 by changing Date custom filter independently' do
    set_datepicker(self, 'grid_f_due_date_fr_date_placeholder', 2022, 0, 1)
    within 'div#grid.wice-grid-container table.wice-grid tbody tr:first-child td.active-filter' do
      expect(page).to have_content('2023-01-26')
    end

    set_datepicker(self, 'grid_f_due_date_to_date_placeholder', 2023, 0, 1)
    within 'div#grid.wice-grid-container table.wice-grid tbody tr:first-child td.active-filter' do
      expect(page).to have_content('2022-07-29')
    end

    within 'div#grid.wice-grid-container .pagination_status' do
      expect(page).to have_content('1-20 / 35')
    end

    within 'div#grid2.wice-grid-container .pagination_status' do
      expect(page).to have_content('1-20 / 50')
    end

    set_datepicker(self, 'grid2_f_due_date_fr_date_placeholder', 2022, 0, 1)
    within 'div#grid2.wice-grid-container table.wice-grid tbody tr:first-child td.active-filter' do
      expect(page).to have_content('2023-01-26')
    end

    set_datepicker(self, 'grid2_f_due_date_to_date_placeholder', 2023, 0, 1)
    within 'div#grid2.wice-grid-container table.wice-grid tbody tr:first-child td.active-filter' do
      expect(page).to have_content('2023-01-26')
    end

    within 'div#grid.wice-grid-container .pagination_status' do
      expect(page).to have_content('1-20 / 35')
    end

    within 'div#grid2.wice-grid-container .pagination_status' do
      expect(page).to have_content('1-20 / 35')
    end

    find(:css, '.grid1 .wg-external-reset-button').click
    within 'div#grid.wice-grid-container .pagination_status' do
      expect(page).to have_content('1-20 / 50')
    end

    within 'div#grid2.wice-grid-container .pagination_status' do
      expect(page).to have_content('1-20 / 35')
    end

    find(:css, '.grid2 .wg-external-reset-button').click

    within 'div#grid.wice-grid-container .pagination_status' do
      expect(page).to have_content('1-20 / 50')
    end

    within 'div#grid2.wice-grid-container .pagination_status' do
      expect(page).to have_content('1-20 / 50')
    end
  end
end
