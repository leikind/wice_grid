# encoding: utf-8
require 'acceptance_helper'

describe 'auto reloads WiceGrid', type: :request, js: true do
  before :each do
    visit '/auto_reloads'
  end

  it 'should filter by Assigned custom filter' do
    select 'Assigned', from: 'grid_f_status_id'

    within '#grid .pagination_status' do
      page.should have_content('1-4 / 4')
    end
  end

  it 'should filter by grid_f_project_id custom filter' do
    select 'Divine Firmware', from: 'grid_f_project_id'

    within '#grid .pagination_status' do
      page.should have_content('1-15 / 15')
    end
  end

  it 'should filter by Added' do
    set_datepicker(self, 'grid_f_created_at_fr_date_placeholder', 2011, 5, 1)
    sleep 1

    set_datepicker(self, 'grid_f_created_at_to_date_placeholder', 2011, 9, 1)
    sleep 1

    # find(:css, '#grid_submit_grid_icon').click

    within '.pagination_status' do
      page.should have_content('1-20 / 29')
    end

    within 'div.wice-grid-container table.wice-grid tbody tr:first-child td.active-filter' do
      page.should have_content('2011-09-13 22:11:12')
    end

    within 'div.wice-grid-container table.wice-grid thead' do
      click_on 'ID'
    end
    sleep 1

    within '.pagination_status' do
      page.should have_content('1-20 / 29')
    end

    within 'ul.pagination' do
      click_link '2'
    end
    sleep 1

    # WTF
    within 'div.wice-grid-container table.wice-grid tbody tr:first-child td.active-filter' do
      page.should have_content('2011-09-22 22:11:12')
    end

    find(:css, '#grid_reset_grid_icon').click
    sleep 1
    within '.pagination_status' do
      page.should have_content('1-20 / 50')
    end
  end

  it 'should filter by Archived' do
    select 'yes', from: 'grid_f_archived'
    # find(:css, '#grid_submit_grid_icon').click

    within '.pagination_status' do
      page.should have_content('1-4 / 4')
    end

    within first(:css, 'td.active-filter') do
      page.should have_content('Yes')
    end

    select 'no', from: 'grid_f_archived'
    # find(:css, '#grid_submit_grid_icon').click

    within '.pagination_status' do
      page.should have_content('1-20 / 46')
    end

    within first(:css, 'td.active-filter') do
      page.should have_content('No')
    end

    within 'ul.pagination' do
      click_link '2'
    end

    within '.pagination_status' do
      page.should have_content('21-40 / 46')
    end

    within first(:css, 'td.active-filter') do
      page.should have_content('No')
    end

    find(:css, '#grid_reset_grid_icon').click
    within '.pagination_status' do
      page.should have_content('1-20 / 50')
    end
  end

  it 'should filter by ID, two limits' do
    fill_in('grid_f_id_fr', with: 507)
    fill_in('grid_f_id_to', with: 509)

    within '.pagination_status' do
      page.should have_content('1-3 / 3')
    end

    within 'div.wice-grid-container table.wice-grid tbody tr:first-child td.active-filter' do
      page.should have_content('507')
    end

    page.should have_content('508')
    page.should have_content('509')

    # ID !!!!
    within 'div.wice-grid-container table.wice-grid thead' do
      click_on 'ID'
    end

    within '.pagination_status' do
      page.should have_content('1-3 / 3')
    end

    within 'div.wice-grid-container table.wice-grid tbody tr:first-child td.sorted.active-filter' do
      page.should have_content('509')
    end

    page.should have_content('508')
    page.should have_content('509')

    # ID !!!!
    within 'div.wice-grid-container table.wice-grid thead' do
      click_on 'ID'
    end

    within '.pagination_status' do
      page.should have_content('1-3 / 3')
    end

    # sleep 10
    within 'div.wice-grid-container table.wice-grid tbody tr:first-child td.sorted' do
      page.should have_content('507')
    end

    within 'div.wice-grid-container table.wice-grid thead' do
      click_on 'Title'
    end

    within '.pagination_status' do
      page.should have_content('1-3 / 3')
    end

    page.should have_content('507')
    page.should have_content('508')
    page.should have_content('509')

    find(:css, '#grid_reset_grid_icon').click
    within '.pagination_status' do
      page.should have_content('1-20 / 50')
    end
  end

  it 'should filter by ID, one limit' do
    fill_in('grid_f_id_fr', with: 550)

    within '.pagination_status' do
      page.should have_content('1-7 / 7')
    end

    within 'div.wice-grid-container table.wice-grid tbody tr:first-child td.active-filter' do
      page.should have_content('550')
    end

    551.upto(556) do |i|
      page.should have_content(i)
    end

    within 'div.wice-grid-container table.wice-grid thead' do
      click_on 'ID'
    end

    within '.pagination_status' do
      page.should have_content('1-7 / 7')
    end

    within 'div.wice-grid-container table.wice-grid tbody tr:first-child td.sorted.active-filter' do
      page.should have_content('556')
    end

    551.upto(556) do |i|
      page.should have_content(i)
    end

    within 'div.wice-grid-container table.wice-grid thead' do
      click_on 'ID'
    end

    within '.pagination_status' do
      page.should have_content('1-7 / 7')
    end

    within 'div.wice-grid-container table.wice-grid tbody tr:first-child td.sorted' do
      page.should have_content('550')
    end

    within 'div.wice-grid-container table.wice-grid thead' do
      click_on 'Title'
    end

    within '.pagination_status' do
      page.should have_content('1-7 / 7')
    end

    550.upto(556) do |i|
      page.should have_content(i)
    end

    find(:css, '#grid_reset_grid_icon').click
    within '.pagination_status' do
      page.should have_content('1-20 / 50')
    end
  end

  it 'should filter by Due Date' do
    set_datepicker(self, 'grid_f_due_date_fr_date_placeholder', 2012, 0, 1)

    sleep 1

    set_datepicker(self, 'grid_f_due_date_to_date_placeholder', 2013, 0, 1)

    sleep 1

    within '.pagination_status' do
      page.should have_content('1-20 / 35')
    end

    within 'div.wice-grid-container table.wice-grid tbody tr:first-child td.active-filter' do
      page.should have_content('2012-07-29')
    end

    within 'div.wice-grid-container table.wice-grid thead' do
      click_on 'ID'
    end

    sleep 1

    within '.pagination_status' do
      page.should have_content('1-20 / 35')
    end

    within 'ul.pagination' do
      click_link '2'
    end

    sleep 1

    within 'div.wice-grid-container table.wice-grid tbody tr:first-child td.active-filter' do
      page.should have_content('2012-07-02')
    end

    set_datepicker(self, 'grid_f_due_date_fr_date_placeholder', 2012, 6, 28)
    sleep 1

    set_datepicker(self, 'grid_f_due_date_to_date_placeholder', 2012, 6, 31)
    sleep 1

    within '.pagination_status' do
      page.should have_content('1-1 / 1')
    end

    find(:css, '#grid_f_due_date_fr_date_view').click

    sleep 1

    within '.pagination_status' do
      page.should have_content('1-10 / 10')
    end

    find(:css, '#grid_f_due_date_to_date_view').click

    sleep 1

    within '.pagination_status' do
      page.should have_content('1-20 / 50')
    end
  end

  it 'should negate the semantics of the text  filter' do
    fill_in('grid_f_title_v', with: 'sed')
    select 'no', from: 'grid_f_archived'

    page.should have_content('sed impedit iste')

    find(:css, '#grid_f_title_n').click

    page.should_not have_content('sed impedit iste')
  end

  it 'should reload the title filter' do
    fill_in('grid_f_title_v', with: 'ed')

    within '.pagination_status' do
      page.should have_content('1-2 / 2')
    end

    within 'div.wice-grid-container table.wice-grid tbody tr:first-child td.active-filter' do
      page.should have_content('sed impedit iste')
    end

    page.should have_content('corporis expedita vel')

    within 'div.wice-grid-container table.wice-grid thead' do
      click_on 'Title'
    end

    within '.pagination_status' do
      page.should have_content('1-2 / 2')
    end

    within 'div.wice-grid-container table.wice-grid tbody tr:first-child td.active-filter' do
      page.should have_content('corporis expedita vel')
    end

    page.should have_content('sed impedit iste')

    within 'div.wice-grid-container table.wice-grid thead' do
      click_on 'ID'
    end

    within '.pagination_status' do
      page.should have_content('1-2 / 2')
    end

    page.should have_content('corporis expedita vel')
    page.should have_content('sed impedit iste')

    find(:css, '#grid_reset_grid_icon').click
    within '.pagination_status' do
      page.should have_content('1-20 / 50')
    end
  end
end
