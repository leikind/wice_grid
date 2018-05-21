# encoding: utf-8
require 'acceptance_helper'

describe 'custom_ordering WiceGrid', type: :request, js: true do
  before :each do
    visit '/custom_ordering'
  end

  it 'should be sorted by the length of the word' do
    within 'div#grid.wice-grid-container table.wice-grid tbody tr:first-child td.sorted' do
      page.should have_content('New')
    end

    within 'div#grid.wice-grid-container table.wice-grid thead' do
      click_on 'Status Name'
    end

    within 'div#grid.wice-grid-container table.wice-grid tbody tr:first-child td.sorted' do
      page.should have_content('Duplicate')
    end
  end

  it 'should be sorted by the position of the status' do
    within 'div#g2.wice-grid-container table.wice-grid tbody tr:first-child td.sorted' do
      page.should have_content('New')
    end

    within 'div#g2.wice-grid-container table.wice-grid thead' do
      click_on 'Status Name'
    end

    within 'div#g2.wice-grid-container table.wice-grid tbody tr:first-child td.sorted' do
      page.should have_content('Verified')
    end
  end
end
