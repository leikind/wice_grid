# encoding: utf-8
require 'acceptance_helper'

describe 'with custom_ordering in controler with Procs WiceGrid', type: :request, js: true do
  context 'when "statuses.name" => ->(column_name) { params[:sort_by_length] ? "length(#{column_name})" : column_name }' do
    context 'with no special param' do
      before :each do
        visit '/custom_ordering_with_proc'
      end

      it 'sorts alphabetically' do
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

    context 'with the :sort_by_length param' do
      before :each do
        visit '/custom_ordering_with_proc?sort_by_length=1'
      end

      it 'sorts by length of the #name' do
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
end
