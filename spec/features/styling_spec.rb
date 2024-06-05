require 'acceptance_helper'

describe "with the :html helper in the grid WiceGrid", :type => :request, :js => true do

  before :each do
    visit '/styling'
  end

  it "allows to have custom css classes" do
    expect(page).to have_selector('.wice-grid-container table.wice-grid.my-grid')

    expect(page).to have_selector('.wice-grid-container thead tr.wice-grid-title-row.my-header')
  end

end
