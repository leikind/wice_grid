# encoding: utf-8
require 'acceptance_helper'

describe 'On the page /all_records WiceGrid', type: :request, js: true do
  before :each do
    visit '/all_records'
  end

  it 'does not allow to show all records' do
    within 'div.wice-grid-container table.wice-grid tbody' do
      expect(page).to have_no_content('show all')
    end
  end

  it 'shows the the range of the records on the current page together with the total number of records' do
    within '.pagination_status' do
      expect(page).to have_content('1-20 / 50')
    end
  end
end
