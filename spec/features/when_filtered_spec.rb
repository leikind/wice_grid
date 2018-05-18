require 'acceptance_helper'

describe "when_filtered WiceGrid",  :js => true do

  before :each do
    visit '/when_filtered'
  end


  it "the filter panel is hidden by default" do
    lambda{
      fill_in('grid_f_description', :with => 've')
    }.should raise_error(Capybara::ElementNotFound)
  end

  it "should filter by Description" do

    find(:css, '.wg-show-filter').click


    fill_in('grid_f_description', :with => 've')

    find(:css, '#grid_submit_grid_icon').click

    within '.pagination_status' do
      page.should have_content('1-12 / 12')
    end

    within 'div.wice-grid-container table.wice-grid tbody tr:first-child td.active-filter' do
      page.should have_content('Velit atque sapiente aspernatur sint fuga.')
    end

    page.should have_content('Vero sit voluptate sed tempora et provident sequi nihil.')

    within 'div.wice-grid-container table.wice-grid thead' do
      click_on 'Description'
    end

    within '.pagination_status' do
      page.should have_content('1-12 / 12')
    end


    within 'div.wice-grid-container table.wice-grid tbody tr:first-child td.active-filter' do
      page.should have_content('Ad sunt vel maxime labore temporibus incidunt quidem.')
    end

    page.should have_content('Adipisci voluptate sed esse velit.')

    within 'div.wice-grid-container table.wice-grid thead' do
      click_on 'ID'
    end

    within '.pagination_status' do
      page.should have_content('1-12 / 12')
    end


    page.should have_content('Adipisci voluptate sed esse velit.')
    page.should have_content('Ad sunt vel maxime labore temporibus incidunt quidem.')

    find(:css, '#grid_reset_grid_icon').click
    within '.pagination_status' do
      page.should have_content('1-20 / 50')
    end

  end



  it "should filter by multiple columns" do

    find(:css, '.wg-show-filter').click

    fill_in('grid_f_description', :with => 'v')
    fill_in('grid_f_title', :with => 's')
    select 'no', :from => 'grid_f_archived'

    find(:css, '#grid_submit_grid_icon').click

    within '.pagination_status' do
      page.should have_content('1-11 / 11')
    end

    page.should have_content('Inventore iure eos labore ipsum.')
    page.should have_content('Velit atque sapiente aspernatur sint fuga.')

    within 'div.wice-grid-container table.wice-grid thead' do
      click_on 'Description'
    end

    within '.pagination_status' do
      page.should have_content('1-11 / 11')
    end

    page.should have_content('Inventore iure eos labore ipsum.')
    page.should have_content('Velit atque sapiente aspernatur sint fuga.')

    find(:css, '#grid_reset_grid_icon').click
    within '.pagination_status' do
      page.should have_content('1-20 / 50')
    end


  end


  it "should filter by Archived" do

    find(:css, '.wg-show-filter').click

    select 'yes', :from => 'grid_f_archived'
    find(:css, '#grid_submit_grid_icon').click

    within '.pagination_status' do
      page.should have_content('1-4 / 4')
    end

    within first(:css, 'td.active-filter') do
      page.should have_content('Yes')
    end

    select 'no', :from => 'grid_f_archived'
    find(:css, '#grid_submit_grid_icon').click

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


  it "should filter by Title" do

    find(:css, '.wg-show-filter').click

    fill_in('grid_f_title', :with => 'ed')

    find(:css, '#grid_submit_grid_icon').click

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
