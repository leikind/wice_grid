# encoding: utf-8
require 'acceptance_helper'

describe 'auto reloads WiceGrid', type: :request, js: true do
  before :each do
    visit '/auto_reloads3'
  end

  # it "should filter grid1 and grid 2 by Archived independently " do
  #   select 'yes', :from => 'grid_f_archived'

  #   within 'div#grid.wice-grid-container .pagination_status' do
  #     page.should have_content('1-4 / 4')
  #   end

  #   within 'div#grid2.wice-grid-container .pagination_status' do
  #     page.should have_content('1-20 / 50')
  #   end

  #   select 'no', :from => 'grid2_f_archived'

  #   within 'div#grid.wice-grid-container .pagination_status' do
  #     page.should have_content('1-4 / 4')
  #   end

  #   within 'div#grid2.wice-grid-container .pagination_status' do
  #     page.should have_content('1-20 / 46')
  #   end
  # end

  # it "should filter grid1 and grid 2 by Status independently " do
  #   select 'Assigned', :from => 'grid_f_status_id'

  #   within 'div#grid.wice-grid-container .pagination_status' do
  #     page.should have_content('1-4 / 4')
  #   end

  #   within 'div#grid2.wice-grid-container .pagination_status' do
  #     page.should have_content('1-20 / 50')
  #   end

  #   select 'Cancelled', :from => 'grid2_f_status_id'

  #   within 'div#grid.wice-grid-container .pagination_status' do
  #     page.should have_content('1-4 / 4')
  #   end

  #   within 'div#grid2.wice-grid-container .pagination_status' do
  #     page.should have_content('1-8 / 8')
  #   end

  # end

  # it "should filter grid1 and grid 2 by Title independently" do

  #   fill_in('grid_f_title_v', :with => 'sed')

  #   within 'div#grid.wice-grid-container .pagination_status' do
  #     page.should have_content('1-1 / 1')
  #   end

  #   fill_in('grid2_f_title_v', :with => 'a')

  #   within 'div#grid.wice-grid-container .pagination_status' do
  #     page.should have_content('1-1 / 1')
  #   end

  #   within 'div#grid2.wice-grid-container .pagination_status' do
  #     page.should have_content('1-20 / 31')
  #   end

  # end

  it 'should filter by Due Date independantly' do
    set_datepicker(self, 'grid_f_due_date_fr_date_placeholder', 2012, 0, 1)

    sleep 1

    set_datepicker(self, 'grid_f_due_date_to_date_placeholder', 2013, 0, 1)

    within 'div#grid.wice-grid-container .pagination_status' do
      page.should have_content('1-20 / 35')
    end

    within 'div#grid2.wice-grid-container .pagination_status' do
      page.should have_content('1-20 / 50')
    end

    set_datepicker(self, 'grid2_f_due_date_fr_date_placeholder', 2012, 0, 1)

    sleep 1

    set_datepicker(self, 'grid2_f_due_date_to_date_placeholder', 2013, 0, 1)

    sleep 1

    within 'div#grid.wice-grid-container .pagination_status' do
      page.should have_content('1-20 / 35')
    end

    within 'div#grid2.wice-grid-container .pagination_status' do
      page.should have_content('1-20 / 35')
    end

    find(:css, '.grid1 .wg-external-reset-button').click
    within 'div#grid.wice-grid-container .pagination_status' do
      page.should have_content('1-20 / 50')
    end

    within 'div#grid2.wice-grid-container .pagination_status' do
      page.should have_content('1-20 / 35')
    end

    find(:css, '.grid2 .wg-external-reset-button').click

    within 'div#grid.wice-grid-container .pagination_status' do
      page.should have_content('1-20 / 50')
    end

    within 'div#grid2.wice-grid-container .pagination_status' do
      page.should have_content('1-20 / 50')
    end
  end
end
