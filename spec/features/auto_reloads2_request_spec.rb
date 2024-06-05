# encoding: utf-8
require 'acceptance_helper'

describe 'On the page /auto_reloads2 with detached filters WiceGrid', type: :feature, js: true do
  before :each do
    visit '/auto_reloads2'
  end

  it 'allows to filter immediately by changing Assigned custom filter' do
    select 'Assigned', from: 'grid_f_status_id'

    within '#grid .pagination_status' do
      expect(page).to have_content('1-4 / 4')
    end
  end

  it 'allows to filter immediately by changing Project custom filter' do
    select 'Divine Firmware', from: 'grid_f_project_id'

    within '#grid .pagination_status' do
      expect(page).to have_content('1-15 / 15')
    end
  end

  it 'allows to filter immediately by changing "Added" custom filter' do
    set_datepicker(self, 'grid_f_created_at_fr_date_placeholder', 2021, 5, 1)
    within 'div.wice-grid-container table.wice-grid tbody tr:first-child td.active-filter' do
      expect(page).to have_content('2021-09-13 22:11:12')
    end

    set_datepicker(self, 'grid_f_created_at_to_date_placeholder', 2021, 9, 1)
    within 'div.wice-grid-container table.wice-grid tbody tr:first-child td.active-filter' do
      expect(page).to have_content('2021-09-13 22:11:12')
    end

    within '.pagination_status' do
      expect(page).to have_content('1-20 / 29')
    end

    within 'div.wice-grid-container table.wice-grid thead' do
      click_on 'ID'
    end

    within 'div.wice-grid-container table.wice-grid tbody tr:first-child td.active-filter' do
      expect(page).to have_content('2021-09-29 22:11:12')
    end

    within '.pagination_status' do
      expect(page).to have_content('1-20 / 29')
    end

    within 'ul.pagination' do
      click_link '2'
    end

    within 'div.wice-grid-container table.wice-grid tbody tr:first-child td.active-filter' do
      expect(page).to have_content('2021-09-22 22:11:12')
    end

    find(:css, '.wg-external-reset-button').click
    within '.pagination_status' do
      expect(page).to have_content('1-20 / 50')
    end
  end

  it 'allows to filter immediately by changing "Archived" custom filter' do
    select 'yes', from: 'grid_f_archived'
    # find(:css, '#grid_submit_grid_icon').click

    within '.pagination_status' do
      expect(page).to have_content('1-4 / 4')
    end

    within first(:css, 'td.active-filter') do
      expect(page).to have_content('Yes')
    end

    select 'no', from: 'grid_f_archived'
    # find(:css, '#grid_submit_grid_icon').click

    within '.pagination_status' do
      expect(page).to have_content('1-20 / 46')
    end

    within first(:css, 'td.active-filter') do
      expect(page).to have_content('No')
    end

    within 'ul.pagination' do
      click_link '2'
    end

    within '.pagination_status' do
      expect(page).to have_content('21-40 / 46')
    end

    within first(:css, 'td.active-filter') do
      expect(page).to have_content('No')
    end

    find(:css, '.wg-external-reset-button').click
    within '.pagination_status' do
      expect(page).to have_content('1-20 / 50')
    end
  end

  it 'allows to filter immediately by changing the fields for ID two limits' do
    fill_in('grid_f_id_fr', with: 507)
    fill_in('grid_f_id_to', with: 509)

    # find(:css, '#grid_submit_grid_icon').click

    within '.pagination_status' do
      expect(page).to have_content('1-3 / 3')
    end

    within 'div.wice-grid-container table.wice-grid tbody tr:first-child td.active-filter' do
      expect(page).to have_content('507')
    end

    expect(page).to have_content('508')
    expect(page).to have_content('509')

    within 'div.wice-grid-container table.wice-grid thead' do
      click_on 'ID'
    end

    within '.pagination_status' do
      expect(page).to have_content('1-3 / 3')
    end

    within 'div.wice-grid-container table.wice-grid tbody tr:first-child td.sorted.active-filter' do
      expect(page).to have_content('509')
    end

    expect(page).to have_content('507')
    expect(page).to have_content('508')
    expect(page).to have_content('509')

    within 'div.wice-grid-container table.wice-grid thead' do
      click_on 'ID'
    end

    within '.pagination_status' do
      expect(page).to have_content('1-3 / 3')
    end

    within 'div.wice-grid-container table.wice-grid tbody tr:first-child td.sorted' do
      expect(page).to have_content('507')
    end

    within 'div.wice-grid-container table.wice-grid thead' do
      click_on 'Title'
    end

    within 'div.wice-grid-container table.wice-grid tbody tr:first-child td.sorted' do
      expect(page).to have_content('ab')
    end

    within '.pagination_status' do
      expect(page).to have_content('1-3 / 3')
    end

    within 'div.wice-grid-container table.wice-grid tbody tr:first-child td.sorted' do
      expect(page).to have_content('ab')
    end

    expect(page).to have_content('507')
    expect(page).to have_content('508')
    expect(page).to have_content('509')

    find(:css, '.wg-external-reset-button').click
    within '.pagination_status' do
      expect(page).to have_content('1-20 / 50')
    end
  end

  it 'allows to filter immediately by changing the field for ID one limit' do
    fill_in('grid_f_id_fr', with: 550)

    # find(:css, '#grid_submit_grid_icon').click

    within '.pagination_status' do
      expect(page).to have_content('1-7 / 7')
    end

    within 'div.wice-grid-container table.wice-grid tbody tr:first-child td.active-filter' do
      expect(page).to have_content('550')
    end

    551.upto(556) do |i|
      expect(page).to have_content(i)
    end

    within 'div.wice-grid-container table.wice-grid thead' do
      click_on 'ID'
    end

    within '.pagination_status' do
      expect(page).to have_content('1-7 / 7')
    end

    within 'div.wice-grid-container table.wice-grid tbody tr:first-child td.sorted.active-filter' do
      expect(page).to have_content('556')
    end

    551.upto(556) do |i|
      expect(page).to have_content(i)
    end

    within 'div.wice-grid-container table.wice-grid thead' do
      click_on 'ID'
    end

    within '.pagination_status' do
      expect(page).to have_content('1-7 / 7')
    end

    within 'div.wice-grid-container table.wice-grid tbody tr:first-child td.sorted' do
      expect(page).to have_content('550')
    end

    within 'div.wice-grid-container table.wice-grid thead' do
      click_on 'Title'
    end

    within '.pagination_status' do
      expect(page).to have_content('1-7 / 7')
    end

    550.upto(556) do |i|
      expect(page).to have_content(i)
    end

    find(:css, '.wg-external-reset-button').click
    within '.pagination_status' do
      expect(page).to have_content('1-20 / 50')
    end
  end

  it 'allows to filter immediately by changing the field for Due Date' do
    set_datepicker(self, 'grid_f_due_date_fr_date_placeholder', 2022, 0, 1)
    within 'div.wice-grid-container table.wice-grid tbody tr:first-child td.active-filter' do
      expect(page).to have_content('2023-01-26')
    end

    set_datepicker(self, 'grid_f_due_date_to_date_placeholder', 2023, 0, 1)
    within 'div.wice-grid-container table.wice-grid tbody tr:first-child td.active-filter' do
      expect(page).to have_content('2022-07-29')
    end

    within '.pagination_status' do
      expect(page).to have_content('1-20 / 35')
    end

    within 'div.wice-grid-container table.wice-grid thead' do
      click_on 'ID'
    end

    within 'div.wice-grid-container table.wice-grid tbody tr:first-child td.active-filter' do
      expect(page).to have_content('2022-10-02')
    end

    within '.pagination_status' do
      expect(page).to have_content('1-20 / 35')
    end

    within 'ul.pagination' do
      click_link '2'
    end

    within 'div.wice-grid-container table.wice-grid tbody tr:first-child td.active-filter' do
      expect(page).to have_content('2022-07-02')
    end

    set_datepicker(self, 'grid_f_due_date_fr_date_placeholder', 2022, 6, 28)
    within 'div.wice-grid-container table.wice-grid tbody tr:first-child td.active-filter' do
      expect(page).to have_content('2022-10-02')
    end

    set_datepicker(self, 'grid_f_due_date_to_date_placeholder', 2022, 6, 31)
    within 'div.wice-grid-container table.wice-grid tbody tr:first-child td.active-filter' do
      expect(page).to have_content('2022-07-29')
    end

    within '.pagination_status' do
      expect(page).to have_content('1-1 / 1')
    end

    find(:css, '#grid_f_due_date_fr_date_view').click

    within '.pagination_status' do
      expect(page).to have_content('1-10 / 10')
    end

    find(:css, '#grid_f_due_date_to_date_view').click

    within '.pagination_status' do
      expect(page).to have_content('1-20 / 50')
    end
  end

  it 'allows to negate filter by clickin the checkbox for "Title" filter' do
    expect(page).to have_content('sequi')
    expect(page).to have_content('sed impedit iste')

    fill_in('grid_f_title_v', with: 'sed')
    select 'no', from: 'grid_f_archived'

    expect(page).to have_no_content('sequi')
    expect(page).to have_content('sed impedit iste')

    find(:css, '#grid_f_title_n').click

    expect(page).to have_content('sequi')
    expect(page).to have_no_content('sed impedit iste')
  end

  it 'allows to reload the title filter' do
    fill_in('grid_f_title_v', with: 'ed')

    within '.pagination_status' do
      expect(page).to have_content('1-2 / 2')
    end

    within 'div.wice-grid-container table.wice-grid tbody tr:first-child td.active-filter' do
      expect(page).to have_content('sed impedit iste')
    end

    expect(page).to have_content('corporis expedita vel')

    within 'div.wice-grid-container table.wice-grid thead' do
      click_on 'Title'
    end

    within '.pagination_status' do
      expect(page).to have_content('1-2 / 2')
    end

    within 'div.wice-grid-container table.wice-grid tbody tr:first-child td.active-filter' do
      expect(page).to have_content('corporis expedita vel')
    end

    expect(page).to have_content('sed impedit iste')

    within 'div.wice-grid-container table.wice-grid thead' do
      click_on 'ID'
    end

    within '.pagination_status' do
      expect(page).to have_content('1-2 / 2')
    end

    expect(page).to have_content('corporis expedita vel')
    expect(page).to have_content('sed impedit iste')

    within 'div.wice-grid-container table.wice-grid tbody tr:first-child td.active-filter' do
      expect(page).to have_content('sed impedit iste')
    end

    find(:css, '.wg-external-reset-button').click
    within '.pagination_status' do
      expect(page).to have_content('1-20 / 50')
    end
  end
end
