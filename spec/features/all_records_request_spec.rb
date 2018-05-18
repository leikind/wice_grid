# encoding: utf-8
require 'acceptance_helper'

describe 'all records WiceGrid', type: :request, js: true do
  before :each do
    visit '/all_records'
  end

  it 'should filter by custom filters' do
    within 'div.wice-grid-container table.wice-grid tbody' do
      page.should_not have_content('show all')
    end

    within '.pagination_status' do
      page.should have_content('1-20 / 50')
    end
  end
end
