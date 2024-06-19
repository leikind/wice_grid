require 'acceptance_helper'

describe "On the page /when_filtered whith the parameter show_filters: :when_filtered in grid WiceGrid",  :js => true do
  before :each do
    visit '/when_filtered'
  end

  it "hides the filter panel by default" do
    expect{
      fill_in('grid_f_description', :with => 've')
    }.to raise_error(Capybara::ElementNotFound)
  end

  context 'when the icon "Show filter is clicked"' do
    before do
      find(:css, '.wg-show-filter').click
    end

    it "allows to filter by Description" do
      fill_in('grid_f_description', :with => 've')

      find(:css, '#grid_submit_grid_icon').click

      within '.pagination_status' do
        expect(page).to have_content('1-12 / 12')
      end

      within 'div.wice-grid-container table.wice-grid tbody tr:first-child td.active-filter' do
        expect(page).to have_content('Velit atque sapiente aspernatur sint fuga.')
      end

      expect(page).to have_content('Vero sit voluptate sed tempora et provident sequi nihil.')

      within 'div.wice-grid-container table.wice-grid thead' do
        click_on 'Description'
      end

      within '.pagination_status' do
        expect(page).to have_content('1-12 / 12')
      end

      within 'div.wice-grid-container table.wice-grid tbody tr:first-child td.active-filter' do
        expect(page).to have_content('Ad sunt vel maxime labore temporibus incidunt quidem.')
      end

      expect(page).to have_content('Adipisci voluptate sed esse velit.')

      within 'div.wice-grid-container table.wice-grid thead' do
        click_on 'ID'
      end

      within '.pagination_status' do
        expect(page).to have_content('1-12 / 12')
      end

      expect(page).to have_content('Adipisci voluptate sed esse velit.')
      expect(page).to have_content('Ad sunt vel maxime labore temporibus incidunt quidem.')

      find(:css, '#grid_reset_grid_icon').click
      within '.pagination_status' do
        expect(page).to have_content('1-20 / 50')
      end
    end

    it "allows to filter by multiple columns" do
      fill_in('grid_f_description', :with => 'v')
      fill_in('grid_f_title', :with => 's')
      select 'no', :from => 'grid_f_archived'

      find(:css, '#grid_submit_grid_icon').click

      within '.pagination_status' do
        expect(page).to have_content('1-11 / 11')
      end

      expect(page).to have_content('Inventore iure eos labore ipsum.')
      expect(page).to have_content('Velit atque sapiente aspernatur sint fuga.')

      within 'div.wice-grid-container table.wice-grid thead' do
        click_on 'Description'
      end

      within '.pagination_status' do
        expect(page).to have_content('1-11 / 11')
      end

      expect(page).to have_content('Inventore iure eos labore ipsum.')
      expect(page).to have_content('Velit atque sapiente aspernatur sint fuga.')

      find(:css, '#grid_reset_grid_icon').click
      within '.pagination_status' do
        expect(page).to have_content('1-20 / 50')
      end
    end

    it "allows to filter by Archived" do
      select 'yes', :from => 'grid_f_archived'
      find(:css, '#grid_submit_grid_icon').click

      within '.pagination_status' do
        expect(page).to have_content('1-4 / 4')
      end

      within first(:css, 'td.active-filter') do
        expect(page).to have_content('Yes')
      end

      select 'no', :from => 'grid_f_archived'
      find(:css, '#grid_submit_grid_icon').click

      within '.pagination_status' do
        expect(page).to have_content('1-20 / 46')
      end

      within first(:css, 'td.active-filter') do
        expect(page).to have_content('No')
      end

      within 'ul.grid.pagination' do
        click_link '2'
      end

      within '.pagination_status' do
        expect(page).to have_content('21-40 / 46')
      end

      within first(:css, 'td.active-filter') do
        expect(page).to have_content('No')
      end

      find(:css, '#grid_reset_grid_icon').click
      within '.pagination_status' do
        expect(page).to have_content('1-20 / 50')
      end
    end

    it "allows to filter by Title" do
      fill_in('grid_f_title', :with => 'ed')

      find(:css, '#grid_submit_grid_icon').click

      within '.pagination_status' do
        expect(page).to have_content('1-2 / 2')
      end

      within 'div.wice-grid-container table.wice-grid tbody tr:first-child td.active-filter' do
        expect(page).to have_content('sed impedit iste')
      end

      expect(page).to have_content('corporis expedita vel')

      within 'div.wice-grid-container table.wice-grid thead' do
        click_on 'Title'
      end

      within '.pagination_status' do
        expect(page).to have_content('1-2 / 2')
      end

      within 'div.wice-grid-container table.wice-grid tbody tr:first-child td.active-filter' do
        expect(page).to have_content('corporis expedita vel')
      end

      expect(page).to have_content('sed impedit iste')

      within 'div.wice-grid-container table.wice-grid thead' do
        click_on 'ID'
      end

      within '.pagination_status' do
        expect(page).to have_content('1-2 / 2')
      end

      expect(page).to have_content('corporis expedita vel')
      expect(page).to have_content('sed impedit iste')

      find(:css, '#grid_reset_grid_icon').click
      within '.pagination_status' do
        expect(page).to have_content('1-20 / 50')
      end
    end
  end
end
