require 'acceptance_helper'

describe "upper pagination panel WiceGrid", :type => :request do
  before :each do
    visit '/upper_pagination_panel'
  end

  if ALL_TESTS
    include_examples "basic task table specs"
    include_examples "names of columns"
  end

  it "upper pagination panel should be present" do
    skip "This test should be run with BROWSER=y in environment" unless ENV['BROWSER']
    expect(page).to have_selector('table.wice-grid thead tr td .pagination li.active')

    within 'table.wice-grid thead tr td .pagination_status' do
      expect(page).to have_content('1-20 / 50')
    end
  end
end
