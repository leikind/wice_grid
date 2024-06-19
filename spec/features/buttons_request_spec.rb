# encoding: utf-8
require 'acceptance_helper'

describe 'with external buttons for Submit and Reset filters WiceGrid', type: :request, js: true do
  before :each do
    visit '/buttons'
  end

  it 'allows to filter by Archived' do
    select 'yes', from: 'grid_f_archived'
    click_button('Submit')

    within '.pagination_status' do
      expect(page).to have_content('1-4 / 4')
    end

    within first(:css, 'td.active-filter') do
      expect(page).to have_content('Yes')
    end

    select 'no', from: 'grid_f_archived'
    click_button('Submit')

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

    click_button('Reset')
    within '.pagination_status' do
      expect(page).to have_content('1-20 / 50')
    end
  end

  it 'allows to filter by Ttile' do
    fill_in('grid_f_title', with: 'ed')

    click_button('Submit')

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

    click_button('Reset')
    within '.pagination_status' do
      expect(page).to have_content('1-20 / 50')
    end
  end

  it 'allows to filter by Description' do
    fill_in('grid_f_description', with: 've')

    click_button('Submit')

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

    click_button('Reset')
    within '.pagination_status' do
      expect(page).to have_content('1-20 / 50')
    end
  end

  it 'allows to filter by multiple columns' do
    fill_in('grid_f_description', with: 'v')
    fill_in('grid_f_title', with: 's')
    select 'no', from: 'grid_f_archived'

    click_button('Submit')

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

    click_button('Reset')
    within '.pagination_status' do
      expect(page).to have_content('1-20 / 50')
    end
  end
end
