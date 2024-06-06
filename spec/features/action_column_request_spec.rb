# encoding: utf-8
require 'acceptance_helper'

describe 'action_column WiceGrid', type: :request, js: true do
  before :each do
    visit '/action_column'
  end

  it 'should select rows' do
    510.upto(520).each do |i|
      find(:css, %(input[type="checkbox"][value="#{i}"])).click
    end

    first(:css, 'button.btn', text: 'Process tasks').click

    expect(page).to have_content('Selected tasks: 510, 511, 512, 513, 514, 515, 516, 517, 518, 519, and 520')
  end

  it 'should select rows with the select all button and deselect them with the deselect button' do
    find(:css, '.clickable.select-all').click

    first(:css, 'button.btn', text: 'Process tasks').click

    expect(page).to have_content('Selected tasks: 507, 508, 509, 510, 511, 512, 513, 514, 515, 516, 517, 518, 519, 520, 521, 522, 523, 524, 525, and 526')

    find(:css, '.clickable.deselect-all').click

    first(:css, 'button.btn', text: 'Process tasks').click

    expect(page).to have_no_content('Selected tasks: 507, 508, 509, 510, 511, 512, 513, 514, 515, 516, 517, 518, 519, 520, 521, 522, 523, 524, 525, and 526')
  end

  it 'should filter by ID inside a form, two limits' do
    fill_in('g_f_id_fr', with: 507)
    fill_in('g_f_id_to', with: 509)

    first(:css, 'button.btn', text: 'Process tasks').click

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

    within '.pagination_status' do
      expect(page).to have_content('1-3 / 3')
    end
  end

  it 'should filter by Archived inside a form' do
    select 'yes', from: 'g_f_archived'
    first(:css, 'button.btn', text: 'Process tasks').click

    within '.pagination_status' do
      expect(page).to have_content('1-4 / 4')
    end

    within first(:css, 'td.active-filter') do
      expect(page).to have_content('Yes')
    end

    select 'no', from: 'g_f_archived'
    first(:css, 'button.btn', text: 'Process tasks').click

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
  end

  it 'should filter by Added inside a form' do
    set_datepicker(self, 'g_f_created_at_fr_date_placeholder', 2021, 5, 1)

    set_datepicker(self, 'g_f_created_at_to_date_placeholder', 2021, 9, 1)

    first(:css, 'button.btn', text: 'Process tasks').click

    within '.pagination_status' do
      expect(page).to have_content('1-20 / 29')
    end

    within 'div.wice-grid-container table.wice-grid tbody tr:first-child td.active-filter' do
      expect(page).to have_content('2021-09-13 22:11:12')
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
      # page.should have_content('2021-08-14 22:11:12')
      expect(page).to have_content('2021-09-22 22:11:12')
    end
  end

  it 'should filter by Due Date' do
    set_datepicker(self, 'g_f_due_date_fr_date_placeholder', 2022, 0, 1)

    set_datepicker(self, 'g_f_due_date_to_date_placeholder', 2023, 0, 1)

    first(:css, 'button.btn', text: 'Process tasks').click

    within '.pagination_status' do
      expect(page).to have_content('1-20 / 35')
    end

    within 'div.wice-grid-container table.wice-grid tbody tr:first-child td.active-filter' do
      expect(page).to have_content('2022-07-29')
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

    within '.pagination_status' do
      expect(page).to have_content('21-35 / 35')
    end

    within 'div.wice-grid-container table.wice-grid tbody tr:first-child td.active-filter' do
      expect(page).to have_content('2022-07-02')
    end

    set_datepicker(self, 'g_f_due_date_fr_date_placeholder', 2022, 6, 28)

    set_datepicker(self, 'g_f_due_date_to_date_placeholder', 2022, 6, 31)

    first(:css, 'button.btn', text: 'Process tasks').click

    within '.pagination_status' do
      expect(page).to have_content('1-1 / 1')
    end

    find(:css, '#g_f_due_date_fr_date_view').click

    first(:css, 'button.btn', text: 'Process tasks').click

    within '.pagination_status' do
      expect(page).to have_content('1-10 / 10')
    end

    find(:css, '#g_f_due_date_to_date_view').click

    first(:css, 'button.btn', text: 'Process tasks').click

    within '.pagination_status' do
      expect(page).to have_content('1-20 / 50')
    end
  end

  it 'should negate the semantics of the text  filter inside a form' do
    fill_in('g_f_title_v', with: 'sed')
    select 'no', from: 'g_f_archived'

    first(:css, 'button.btn', text: 'Process tasks').click

    expect(page).to have_content('sed impedit iste')

    find(:css, '#g_f_title_n').click

    first(:css, 'button.btn', text: 'Process tasks').click

    expect(page).to have_no_content('sed impedit iste')
  end

  it 'should reload the title filter' do
    fill_in('g_f_title_v', with: 'ed')

    first(:css, 'button.btn', text: 'Process tasks').click

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
  end
end
