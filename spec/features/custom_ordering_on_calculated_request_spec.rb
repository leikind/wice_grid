# encoding: utf-8
require 'acceptance_helper'

describe 'custom_ordering on calculated WiceGrid', type: :request, js: true do
  before :each do
    visit '/custom_ordering_on_calculated'
  end

  it 'should be sorted by the number of tasks' do
    within 'div#grid.wice-grid-container table.wice-grid' do
      within 'tbody tr:first-child' do
        expect(page).to have_content('New')
      end

      within 'thead' do
        click_on 'Task Count'
      end

      within 'tbody tr:first-child' do
        expect(page).to have_content('New')
        within 'td.sorted' do
          expect(page).to have_content('3')
        end
      end

      within 'thead' do
        click_on 'Task Count'
      end

      within 'tbody tr:first-child' do
        expect(page).to have_content('Duplicate')
        within 'td.sorted' do
          expect(page).to have_content('10')
        end
      end
    end
  end
end
