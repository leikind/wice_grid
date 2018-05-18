require 'acceptance_helper'

describe "styling WiceGrid", :type => :request, :js => true do

  before :each do
    visit '/styling'
  end

  it "should have custom css classes" do
    page.should have_selector('.wice-grid-container table.wice-grid.my-grid')

    page.should have_selector('.wice-grid-container thead tr.wice-grid-title-row.my-header')
  end

end
