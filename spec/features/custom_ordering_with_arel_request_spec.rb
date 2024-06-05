# encoding: utf-8
require 'acceptance_helper'

describe 'with custom_ordering in controler with Arel WiceGrid', type: :request, js: true do
  before :each do
    visit '/custom_ordering_with_arel'
  end

  context 'when "statuses.name" => Arel.sql("length( ? )")' do
    it 'sorts by the length of the word' do
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

  context 'when "statuses.name" => Status.arel_table[:position]' do
    it 'sorts by the position of the status' do
      within 'div#g2.wice-grid-container table.wice-grid tbody tr:first-child td.sorted' do
        expect(page).to have_content('New')
      end

      within 'div#g2.wice-grid-container table.wice-grid thead' do
        click_on 'Status Name'
      end

      within 'div#g2.wice-grid-container table.wice-grid tbody tr:first-child td.sorted' do
        expect(page).to have_content('Verified')
      end
    end
  end
end
