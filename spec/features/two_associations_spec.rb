require 'acceptance_helper'

context 'when two associations referring to the same model are joined' do
  describe "with the help of :table_alias WiceGrid", :type => :request, :js => true do
    before :each do
      visit '/two_associations'
    end

    it "allows to filter the two associations independantly" do
      fill_in('grid_f_companies_name', :with => 'MNU')

      find(:css, '#grid_submit_grid_icon').click

      within '.pagination_status' do
        expect(page).to have_content('1-2 / 2')
      end

      fill_in('grid_f_suppliers_projects_name', :with => 'Coders')

      find(:css, '#grid_submit_grid_icon').click

      within '.pagination_status' do
        expect(page).to have_content('1-1 / 1')
      end

      fill_in('grid_f_companies_name', :with => '')

      find(:css, '#grid_submit_grid_icon').click

      within '.pagination_status' do
        expect(page).to have_content('1-2 / 2')
      end

      fill_in('grid_f_companies_name', :with => 'foo')

      find(:css, '#grid_submit_grid_icon').click

      within '.pagination_status' do
        expect(page).to have_content('0')
      end
    end
  end
end
