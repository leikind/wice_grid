# encoding: utf-8
require 'acceptance_helper'

describe 'with_resultset WiceGrid', type: :request, js: true do
  before :each do
    visit '/resultset_processings'
  end

  it 'should return records displayed on the page' do
    page.should have_content('10 records on the current page: 540, 519, 507, 537, 551, 515, 511, 524, 542, and 523')

    fill_in('g_f_title', with: 'ed')

    sleep 1

    page.should have_content('2 records on the current page: 507 and 534')

    find(:css, '#g_reset_grid_icon').click
    sleep 1

    select 'Cancelled',  from: 'g_f_status_id'
    sleep 1

    page.should have_content('8 records on the current page: 531, 551, 515, 511, 524, 542, 523, and 527')

    find(:css, '#g_reset_grid_icon').click
    sleep 1

    select 'no',  from: 'g_f_archived'
    sleep 1

    page.should have_content('10 records on the current page: 540, 519, 507, 537, 551, 515, 511, 542, 523, and 527')
  end
end
