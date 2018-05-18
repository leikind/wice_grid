require 'acceptance_helper'

describe "two_associations WiceGrid", :type => :request, :js => true do

  before :each do
    visit '/two_associations'
  end


  it "should  filter the two associations independantly" do
    fill_in('grid_f_companies_name', :with => 'MNU')

    find(:css, '#grid_submit_grid_icon').click

    within '.pagination_status' do
      page.should have_content('1-2 / 2')
    end


    fill_in('grid_f_suppliers_projects_name', :with => 'Coders')

    find(:css, '#grid_submit_grid_icon').click

    within '.pagination_status' do
      page.should have_content('1-1 / 1')
    end

    fill_in('grid_f_companies_name', :with => '')

    find(:css, '#grid_submit_grid_icon').click

    within '.pagination_status' do
      page.should have_content('1-2 / 2')
    end

    fill_in('grid_f_companies_name', :with => 'foo')

    find(:css, '#grid_submit_grid_icon').click

    within '.pagination_status' do
      page.should have_content('0')
    end


  end


end
