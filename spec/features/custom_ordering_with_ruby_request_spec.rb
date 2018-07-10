# encoding: utf-8
require 'acceptance_helper'

describe 'custom_ordering with Ruby WiceGrid', type: :request, js: true do
  before :each do
    visit '/custom_ordering_with_ruby'
  end

  it 'should be sorted by the number of vowels' do
    within 'div#grid.wice-grid-container table.wice-grid' do
      within 'tbody tr:first-child' do
        expect(page).to have_content('New')
      end

      within 'thead' do
        click_on 'Status Name'
        expect(page).to have_selector('i.fa-arrow-down')
      end

      expect(page).to have_selector('tbody tr:first-child td.sorted', text: 'New')

      within 'thead' do
        click_on 'Status Name'
        expect(page).to have_selector('i.fa-arrow-up')
      end

      expect(page).to have_selector('tbody tr:first-child td.sorted', text: 'Duplicate')
    end
  end
end
