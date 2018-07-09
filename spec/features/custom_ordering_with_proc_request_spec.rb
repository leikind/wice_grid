# encoding: utf-8
require 'acceptance_helper'

describe 'custom_ordering with Procs WiceGrid', type: :request, js: true do
  context 'with no special param' do
    before :each do
      visit '/custom_ordering_with_proc'
    end

    it 'should be sorted alphabetically' do
      within 'div#grid.wice-grid-container table.wice-grid tbody tr:first-child td.sorted' do
        expect(page).to have_content('Assigned')
      end

      within 'div#grid.wice-grid-container table.wice-grid thead' do
        click_on 'Status Name'
      end

      within 'div#grid.wice-grid-container table.wice-grid tbody tr:first-child td.sorted' do
        expect(page).to have_content('Verified')
      end
    end
  end

  context 'with the sort by length param' do
    before :each do
      visit '/custom_ordering_with_proc?sort_by_length=1'
    end

    it 'should be sorted by length' do
      within 'div#grid.wice-grid-container table.wice-grid tbody tr:first-child td.sorted' do
        expect(page).to have_content('New')
      end

      within 'div#grid.wice-grid-container table.wice-grid thead' do
        click_on 'Status Name'
      end

      within 'div#grid.wice-grid-container table.wice-grid tbody tr:first-child td.sorted' do
        expect(page).to have_content('Duplicate')
      end
    end
  end
end
