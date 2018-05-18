# encoding: utf-8
require 'acceptance_helper'

describe 'many_grids_on_page WiceGrid', type: :request, js: true do
  before :each do
    visit '/many_grids_on_page'
  end

  it 'should sort independantly' do
    within 'div#g1.wice-grid-container table.wice-grid thead' do
      click_on 'Title'
    end

    within 'div#g1.wice-grid-container table.wice-grid tbody tr:first-child td.sorted' do
      page.should have_content('ab')
    end

    within 'div#g2.wice-grid-container table.wice-grid thead' do
      click_on 'Description'
    end

    within 'div#g1.wice-grid-container table.wice-grid thead th.sorted a.asc' do
      page.should have_content('Title')
    end

    within 'div#g2.wice-grid-container table.wice-grid thead th.sorted a.asc' do
      page.should have_content('Description')
    end

    within 'div#g1.wice-grid-container table.wice-grid tbody tr:first-child td.sorted' do
      page.should have_content('ab')
    end

    within 'div#g2.wice-grid-container table.wice-grid tbody tr:first-child td.sorted' do
      page.should have_content('Accusamus voluptas sunt deleniti iusto dolorem repudiandae.')
    end
  end

  it 'should paginate independantly' do
    within '#g1 ul.pagination' do
      click_link '2'
    end

    within '#g2 ul.pagination' do
      click_link '3'
    end

    within '#g1 ul.pagination li.active' do
      page.should have_content('2')
    end

    within '#g2 ul.pagination li.active' do
      page.should have_content('3')
    end
  end

  it 'should show all records independantly for the two grids' do
    within '#g1' do
      click_on 'show all'
    end

    within 'div#g1.wice-grid-container table.wice-grid' do
      page.should have_selector('a.wg-back-to-pagination-link')
    end

    within '#g1 .pagination_status' do
      page.should have_content('1-50 / 50')
    end

    within '#g2 .pagination_status' do
      page.should have_content('1-20 / 50')
    end
  end

  it 'should filter independantly' do
    fill_in('g1_f_description', with: 've')

    find(:css, '#g1_submit_grid_icon').click

    within '#g1 .pagination_status' do
      page.should have_content('1-12 / 12')
    end

    within 'div#g1.wice-grid-container table.wice-grid tbody tr:first-child td.active-filter' do
      page.should have_content('Velit atque sapiente aspernatur sint fuga.')
    end

    fill_in('g2_f_description', with: 'voluptas')

    find(:css, '#g2_submit_grid_icon').click

    within '#g2 .pagination_status' do
      page.should have_content('1-1 / 1')
    end

    within 'div#g2.wice-grid-container table.wice-grid tbody tr:first-child td.active-filter' do
      page.should have_content('Accusamus voluptas sunt deleniti iusto dolorem repudiandae.')
    end

    within '#g1 .pagination_status' do
      page.should have_content('1-12 / 12')
    end

    within 'div#g1.wice-grid-container table.wice-grid tbody tr:first-child td.active-filter' do
      page.should have_content('Velit atque sapiente aspernatur sint fuga.')
    end
  end
end
