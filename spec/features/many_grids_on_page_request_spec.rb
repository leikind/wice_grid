# encoding: utf-8
require 'acceptance_helper'

describe 'On the page /many_grids_on_page with multiple girds on the page WiceGrid', type: :request, js: true do
  before :each do
    visit '/many_grids_on_page'
  end

  it 'allows to sort independantly' do
    within 'div#g1.wice-grid-container table.wice-grid thead' do
      click_on 'Title'
    end

    within 'div#g1.wice-grid-container table.wice-grid tbody tr:first-child td.sorted' do
      expect(page).to have_content('ab')
    end

    within 'div#g2.wice-grid-container table.wice-grid thead' do
      click_on 'Description'
    end

    within 'div#g1.wice-grid-container table.wice-grid thead th.sorted a.asc' do
      expect(page).to have_content('Title')
    end

    within 'div#g2.wice-grid-container table.wice-grid thead th.sorted a.asc' do
      expect(page).to have_content('Description')
    end

    within 'div#g1.wice-grid-container table.wice-grid tbody tr:first-child td.sorted' do
      expect(page).to have_content('ab')
    end

    within 'div#g2.wice-grid-container table.wice-grid tbody tr:first-child td.sorted' do
      expect(page).to have_content('Accusamus voluptas sunt deleniti iusto dolorem repudiandae.')
    end
  end

  it 'allows to paginate independantly' do
    within '#g1 ul.pagination' do
      click_link '2'
    end

    expect(page).to have_selector('#g1 ul.pagination li.active', text: '2')

    within '#g2 ul.pagination' do
      click_link '3'
    end

    expect(page).to have_selector('#g2 ul.pagination li.active', text: '3')
  end

  it 'allows to show all records independantly for the two grids' do
    within '#g1' do
      click_on 'show all'
    end

    within 'div#g1.wice-grid-container table.wice-grid' do
      expect(page).to have_selector('a.wg-back-to-pagination-link')
    end

    within '#g1 .pagination_status' do
      expect(page).to have_content('1-50 / 50')
    end

    within '#g2 .pagination_status' do
      expect(page).to have_content('1-20 / 50')
    end
  end

  it 'allows to filter independantly' do
    fill_in('g1_f_description', with: 've')

    find(:css, '#g1_submit_grid_icon').click

    within '#g1 .pagination_status' do
      expect(page).to have_content('1-12 / 12')
    end

    within 'div#g1.wice-grid-container table.wice-grid tbody tr:first-child td.active-filter' do
      expect(page).to have_content('Velit atque sapiente aspernatur sint fuga.')
    end

    fill_in('g2_f_description', with: 'voluptas')

    find(:css, '#g2_submit_grid_icon').click

    within '#g2 .pagination_status' do
      expect(page).to have_content('1-1 / 1')
    end

    within 'div#g2.wice-grid-container table.wice-grid tbody tr:first-child td.active-filter' do
      expect(page).to have_content('Accusamus voluptas sunt deleniti iusto dolorem repudiandae.')
    end

    within '#g1 .pagination_status' do
      expect(page).to have_content('1-12 / 12')
    end

    within 'div#g1.wice-grid-container table.wice-grid tbody tr:first-child td.active-filter' do
      expect(page).to have_content('Velit atque sapiente aspernatur sint fuga.')
    end
  end
end
