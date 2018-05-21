# encoding: utf-8
require 'acceptance_helper'

describe 'auto reloads WiceGrid', type: :request, js: true do
  before :each do
    visit '/saved_queries'
  end

  def delete_all_saved_queries(context)
    while delete_link = context.find(:css, '.wice-grid-delete-query')
      delete_link.click
    end
  rescue Capybara::ElementNotFound, Selenium::WebDriver::Error::StaleElementReferenceError
    true
  end

  it 'should filter by Added' do
    check_saved_query = lambda do
      within '.pagination_status' do
        page.should have_content('1-20 / 29')
      end

      within 'div.wice-grid-container table.wice-grid tbody tr:first-child td.active-filter' do
        page.should have_content('2011-08-13 22:11:12')
      end
    end

    delete_all_saved_queries self

    set_datepicker(self, 'grid_f_created_at_fr_date_placeholder', 2011, 5, 1)

    set_datepicker(self, 'grid_f_created_at_to_date_placeholder', 2011, 9, 1)

    find(:css, '#grid_submit_grid_icon').click

    # TO DO: find out why this randomly fails without sleep 1
    sleep 1

    within 'div.wice-grid-container table.wice-grid thead' do
      click_on 'Title'
    end

    check_saved_query.call

    fill_in('grid_saved_query_name', with: 'test query 1')
    click_on 'Save the state of filters'

    sleep 1

    page.should have_content('Query saved.')
    page.should have_content('test query 1')

    find(:css, '#grid_reset_grid_icon').click
    within '.pagination_status' do
      page.should have_content('1-20 / 50')
    end

    page.should have_content('test query 1')

    find(:css, '.wice-grid-query-load-link[title="Load query test query 1"]').click

    check_saved_query.call

    within '.wice-grid-container' do
      page.should have_content('test query 1')
    end

    delete_all_saved_queries self
    page.should have_content('Saved query deleted.')
  end

  it 'should filter by Archived and Project Name' do
    check_saved_query = lambda do
      within '.pagination_status' do
        page.should have_content('1-2 / 2')
      end

      within first(:css, 'td.active-filter') do
        page.should have_content('Ultimate Website')
      end
    end

    delete_all_saved_queries self

    select 'yes', from: 'grid_f_archived'
    select 'Ultimate Website', from: 'grid_f_project_id'

    find(:css, '#grid_submit_grid_icon').click

    check_saved_query.call

    fill_in('grid_saved_query_name', with: 'test query 2')
    click_on 'Save the state of filters'

    sleep 1

    page.should have_content('Query saved.')
    page.should have_content('test query 2')

    find(:css, '#grid_reset_grid_icon').click
    within '.pagination_status' do
      page.should have_content('1-20 / 50')
    end

    page.should have_content('test query 2')

    find(:css, '.wice-grid-query-load-link[title="Load query test query 2"]').click

    check_saved_query.call

    within '.wice-grid-container' do
      page.should have_content('test query 2')
    end

    delete_all_saved_queries self
    page.should have_content('Saved query deleted.')
  end
end
