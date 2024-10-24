# encoding: utf-8
require 'acceptance_helper'

describe 'On the page /detached_filters_two_grids with detached filters and 2 grids WiceGrid', type: :feature, js: true do
  before :each do
    visit '/detached_filters_two_grids'
  end

  it 'the filters are independent of each other' do
    select 'yes', from: 'grid_f_archived'

    find(:css, '.external-buttons-grid1 .wg-external-submit-button').click

    within 'div#grid.wice-grid-container .pagination_status' do
      expect(page).to have_content('1-4 / 4')
    end

    select 'no', from: 'grid2_f_archived'
    find(:css, '.external-buttons-grid2 .wg-external-submit-button').click

    # stays the same
    within 'div#grid.wice-grid-container .pagination_status' do
      expect(page).to have_content('1-4 / 4')
    end

    within 'div#grid2.wice-grid-container .pagination_status' do
      expect(page).to have_content('1-20 / 46')
    end

    set_datepicker(self, 'grid_f_due_date_fr_date_placeholder', 2022, 11, 1)
    set_datepicker(self, 'grid_f_due_date_to_date_placeholder', 2022, 11, 31)
    find(:css, '.external-buttons-grid1 .wg-external-submit-button').click

    within 'div#grid.wice-grid-container .pagination_status' do
      expect(page).to have_content('1-3 / 3')
    end

    set_datepicker(self, 'grid2_f_due_date_fr_date_placeholder', 2023, 0, 1)
    set_datepicker(self, 'grid2_f_due_date_to_date_placeholder', 2023, 11, 31)
    find(:css, '.external-buttons-grid2 .wg-external-submit-button').click

    # stays the same
    within 'div#grid.wice-grid-container .pagination_status' do
      expect(page).to have_content('1-3 / 3')
    end

    within 'div#grid2.wice-grid-container .pagination_status' do
      expect(page).to have_content('1-15 / 15')
    end

    find(:css, '.external-buttons-grid1 .wg-external-reset-button').click

    expect(page).to have_select('grid_f_archived', selected: '--')
    expect(page).to have_selector('#grid_f_due_date_fr_date_placeholder:not([value])')
    expect(page).to have_selector('#grid_f_due_date_to_date_placeholder:not([value])')

    within 'div#grid.wice-grid-container .pagination_status' do
      expect(page).to have_content('1-20 / 50')
    end

    within 'div#grid2.wice-grid-container .pagination_status' do
      expect(page).to have_content('1-15 / 15')
    end

    find(:css, '.external-buttons-grid2 .wg-external-reset-button').click

    expect(page).to have_select('grid2_f_archived', selected: '--')
    expect(page).to have_selector('#grid2_f_due_date_fr_date_placeholder:not([value])')
    expect(page).to have_selector('#grid2_f_due_date_to_date_placeholder:not([value])')

    within 'div#grid.wice-grid-container .pagination_status' do
      expect(page).to have_content('1-20 / 50')
    end

    within 'div#grid2.wice-grid-container .pagination_status' do
      expect(page).to have_content('1-20 / 50')
    end

    fill_in('grid_f_title', with: 'ed')

    find(:css, '.external-buttons-grid1 .wg-external-submit-button').click

    within 'div#grid.wice-grid-container .pagination_status' do
      expect(page).to have_content('1-2 / 2')
    end

    within 'div#grid2.wice-grid-container .pagination_status' do
      expect(page).to have_content('1-20 / 50')
    end

    within 'div#grid.wice-grid-container table.wice-grid tbody tr:first-child td.active-filter' do
      expect(page).to have_content('sed impedit iste')
    end

    fill_in('grid2_f_title', with: 'qui')

    find(:css, '.external-buttons-grid2 .wg-external-submit-button').click

    within 'div#grid.wice-grid-container .pagination_status' do
      expect(page).to have_content('1-2 / 2')
    end

    within 'div#grid2.wice-grid-container .pagination_status' do
      expect(page).to have_content('1-5 / 5')
    end

    within 'div#grid.wice-grid-container table.wice-grid tbody tr:first-child td.active-filter' do
      expect(page).to have_content('sed impedit iste')
    end

    within 'div#grid2.wice-grid-container table.wice-grid tbody tr:first-child td.active-filter' do
      expect(page).to have_content('sequi')
    end

    fill_in('grid2_f_description', with: 'in')

    find(:css, '.external-buttons-grid2 .wg-external-submit-button').click

    within 'div#grid.wice-grid-container .pagination_status' do
      expect(page).to have_content('1-2 / 2')
    end

    within 'div#grid2.wice-grid-container .pagination_status' do
      expect(page).to have_content('1-2 / 2')
    end

    within 'div#grid.wice-grid-container table.wice-grid tbody tr:first-child td.active-filter' do
      expect(page).to have_content('sed impedit iste')
    end

    within first(:css, 'div#grid2.wice-grid-container table.wice-grid tbody tr:first-child td.active-filter') do
      expect(page).to have_content('sequi')
    end
  end
end
