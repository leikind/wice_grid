# encoding: utf-8
require 'acceptance_helper'

describe 'with the methods #current_page_records & #all_pages_records WiceGrid', type: :request, js: true do
  before :each do
    visit '/integration_with_application_view'
  end

  it 'returns records displayed on the page and throughout all pages' do
    all_records_current_page_text = '10 records on the current page: 507, 519, 537, 540, 511, 515, 523, 524, 527, and 531'
    all_records_all_pages_text = '50 records throughout all pages: 507, 519, 537, 540, 511, 515, 523, 524, 527, 531, 542, 551, 518, 520, 532, 535, 539, 512, 514, 516, 521, 522, 543, 544, 546, 550, 552, 510, 541, 553, 508, 513, 528, 529, 548, 556, 525, 534, 547, 555, 509, 517, 526, 536, 538, 545, 549, 530, 533, and 554'

    expect(page).to have_content(all_records_current_page_text)
    expect(page).to have_content(all_records_all_pages_text)

    fill_in('g_f_title', with: 'ed')

    expect(page).to have_content('2 records throughout all pages: 507 and 534')
    expect(page).to have_content('2 records on the current page: 507 and 534')

    find(:css, '#g_reset_grid_icon').click

    expect(page).to have_field('g_f_title', with: '')
    expect(page).to have_content(all_records_current_page_text)
    expect(page).to have_content(all_records_all_pages_text)

    select 'Cancelled',  from: 'g_f_status_id'

    expect(page).to have_content('8 records on the current page: 511, 515, 523, 524, 527, 531, 542, and 551')
    expect(page).to have_content('8 records throughout all pages: 511, 515, 523, 524, 527, 531, 542, and 551')

    find(:css, '#g_reset_grid_icon').click

    expect(page).to have_select('g_f_status_id', selected: '--')
    expect(page).to have_content(all_records_current_page_text)
    expect(page).to have_content(all_records_all_pages_text)

    select 'no',  from: 'g_f_archived'

    expect(page).to have_content('10 records on the current page: 507, 519, 537, 540, 511, 515, 523, 527, 531, and 542')
    expect(page).to have_content('46 records throughout all pages: 507, 519, 537, 540, 511, 515, 523, 527, 531, 542, 551, 518, 520, 532, 535, 539, 512, 514, 516, 521, 522, 543, 544, 546, 552, 510, 541, 553, 508, 528, 529, 548, 556, 525, 534, 547, 555, 509, 517, 526, 536, 538, 545, 549, 530, and 554')
  end
end
