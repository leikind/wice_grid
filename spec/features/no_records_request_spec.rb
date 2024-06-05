# encoding: utf-8
require 'acceptance_helper'

context 'when there is no records to show' do
  describe 'with the grid helper :blank_slate WiceGrid', type: :request, js: true do
    before :each do
      visit '/no_records'
    end

    it 'allows to show the message "No Records" in a block for example 1' do
      within '.example1' do
        expect(page).to have_content('No records found')
      end
    end

    it 'allows to show the message "No Records" in a block for example 2' do
      within '.example2' do
        expect(page).to have_content('No records found')
      end
    end

    it 'allows to show the message "No Records" in a block for example 3' do
      within '.example3' do
        expect(page).to have_content('No records found')
      end
    end
  end
end
