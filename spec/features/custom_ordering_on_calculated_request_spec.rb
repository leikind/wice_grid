# encoding: utf-8
require 'acceptance_helper'

describe 'custom_ordering on calculated WiceGrid', type: :request, js: true do
  before :each do
    visit '/custom_ordering_on_calculated'
  end

  it 'should be sorted by the number of tasks' do
    within 'div#grid.wice-grid-container table.wice-grid' do
      expect(page).to have_selector('tbody tr:first-child', text: 'New')

      within 'thead' do
        click_on 'Task Count'
        expect(page).to have_selector('i.fa-arrow-down')
      end

      expect(page).to have_selector('tbody tr:first-child', text: 'New')
      expect(page).to have_selector('tbody tr:first-child td.sorted', text: '3')

      within 'thead' do
        click_on 'Task Count'
        expect(page).to have_selector('i.fa-arrow-up')
      end

      expect(page).to have_selector('tbody tr:first-child', text: 'Duplicate')
      expect(page).to have_selector('tbody tr:first-child td.sorted', text: '10')
    end
  end
end
