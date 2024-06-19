# encoding: utf-8
require 'acceptance_helper'

describe 'On the page /saved_queries when saved queries are configured WiceGrid', type: :request, js: true do
  before :each do
    visit '/saved_queries'
  end

  def delete_all_saved_queries(context)
    while delete_link = context.find(:css, '.wice-grid-delete-query')
      delete_link.click
      expect(page).to have_selector('#grid_notification_messages', text: 'Saved query deleted.')
    end
  rescue Capybara::ElementNotFound
    true
  end

  it 'allows to filter by Added' do
    check_saved_query = lambda do
      within '.pagination_status' do
        expect(page).to have_content('1-20 / 29')
      end

      within 'div.wice-grid-container table.wice-grid tbody tr:first-child td.active-filter' do
        expect(page).to have_content('2021-08-13 22:11:12')
      end
    end

    delete_all_saved_queries self

    set_datepicker(self, 'grid_f_created_at_fr_date_placeholder', 2021, 5, 1)

    set_datepicker(self, 'grid_f_created_at_to_date_placeholder', 2021, 9, 1)

    find(:css, '#grid_submit_grid_icon').click

    within 'div.wice-grid-container table.wice-grid tbody tr:first-child td.active-filter' do
      expect(page).to have_content('2021-09-13 22:11:12')
    end

    within 'div.wice-grid-container table.wice-grid thead' do
      click_on 'Title'
    end

    within 'div.wice-grid-container table.wice-grid tbody tr:first-child td.active-filter' do
      expect(page).to have_content('2021-08-13 22:11:12')
    end

    check_saved_query.call

    fill_in('grid_saved_query_name', with: 'test query 1')
    click_on 'Save the state of filters'

    expect(page).to have_content('Query saved.')
    expect(page).to have_content('test query 1')

    find(:css, '#grid_reset_grid_icon').click
    within '.pagination_status' do
      expect(page).to have_content('1-20 / 50')
    end

    expect(page).to have_content('test query 1')

    find(:css, '.wice-grid-query-load-link[title="Load query test query 1"]').click

    check_saved_query.call

    within '.wice-grid-container' do
      expect(page).to have_content('test query 1')
    end

    delete_all_saved_queries self
    expect(page).to have_content('Saved query deleted.')
  end

  it 'allows to filter by Archived and Project Name' do
    check_saved_query = lambda do
      within '.pagination_status' do
        expect(page).to have_content('1-2 / 2')
      end

      within first(:css, 'td.active-filter') do
        expect(page).to have_content('Ultimate Website')
      end
    end

    delete_all_saved_queries self

    select 'yes', from: 'grid_f_archived'
    select 'Ultimate Website', from: 'grid_f_project_id'

    find(:css, '#grid_submit_grid_icon').click

    check_saved_query.call

    fill_in('grid_saved_query_name', with: 'test query 2')
    click_on 'Save the state of filters'

    expect(page).to have_content('Query saved.')
    expect(page).to have_content('test query 2')

    find(:css, '#grid_reset_grid_icon').click
    within '.pagination_status' do
      expect(page).to have_content('1-20 / 50')
    end

    expect(page).to have_content('test query 2')

    find(:css, '.wice-grid-query-load-link[title="Load query test query 2"]').click

    check_saved_query.call

    within '.wice-grid-container' do
      expect(page).to have_content('test query 2')
    end

    delete_all_saved_queries self
    expect(page).to have_content('Saved query deleted.')
  end
end
