# encoding: utf-8
require 'acceptance_helper'

describe 'current_page_records & all_pages_records WiceGrid', type: :request, js: true do
  before :each do
    visit '/integration_with_application_view'
  end

  it 'should return records displayed on the page and throughout all pages' do
    page.should have_content('10 records on the current page: 540, 519, 507, 537, 551, 515, 511, 524, 542, and 523')
    page.should have_content('50 records throughout all pages: 540, 519, 507, 537, 531, 551, 515, 511, 524, 542, 523, 527, 518, 535, 539, 520, 532, 512, 514, 522, 546, 516, 521, 544, 543, 550, 552, 510, 541, 553, 529, 508, 513, 528, 556, 548, 547, 525, 534, 555, 549, 536, 545, 509, 517, 538, 526, 554, 530, and 533')

    fill_in('g_f_title', with: 'ed')
    sleep 1

    page.should have_content('2 records throughout all pages: 507 and 534')
    page.should have_content('2 records on the current page: 507 and 534')

    find(:css, '#g_reset_grid_icon').click
    sleep 1

    select 'Cancelled',  from: 'g_f_status_id'
    sleep 1

    page.should have_content('8 records on the current page: 531, 551, 515, 511, 524, 542, 523, and 527')
    page.should have_content('8 records throughout all pages: 531, 551, 515, 511, 524, 542, 523, and 527')

    find(:css, '#g_reset_grid_icon').click
    sleep 1

    select 'no',  from: 'g_f_archived'
    sleep 1

    page.should have_content('10 records on the current page: 540, 519, 507, 537, 551, 515, 511, 542, 523, and 527')
    page.should have_content('46 records throughout all pages: 540, 519, 507, 537, 531, 551, 515, 511, 542, 523, 527, 518, 535, 539, 520, 532, 512, 514, 522, 546, 516, 521, 544, 543, 552, 510, 541, 553, 529, 508, 528, 556, 548, 547, 525, 534, 555, 549, 536, 545, 509, 517, 538, 526, 554, and 530')
  end
end
