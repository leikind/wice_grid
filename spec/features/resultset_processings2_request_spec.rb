# encoding: utf-8
require 'acceptance_helper'

describe 'with_resultset WiceGrid', type: :request, js: true do
  before :each do
    visit '/resultset_processings2'
  end

  it 'should show records displayed on all pages' do
    find(:css, '#process').click
    expect(page).to have_content('50 records on all pages: 507, 519, 537, 540, 511, 515, 523, 524, 527, 531, 542, 551, 518, 520, 532, 535, 539, 512, 514, 516, 521, 522, 543, 544, 546, 550, 552, 510, 541, 553, 508, 513, 528, 529, 548, 556, 525, 534, 547, 555, 509, 517, 526, 536, 538, 545, 549, 530, 533, and 554')
  end

  it 'should show records displayed on all pages with a text filter selection' do
    fill_in('g_f_title', with: 'ed')
    sleep 2
    find(:css, '#process').click
    expect(page).to have_content('2 records on all pages: 507 and 534')
  end

  it 'should show records displayed on all pages with a custom filter selection' do
    select 'Cancelled',  from: 'g_f_status_id'
    sleep 2
    find(:css, '#process').click
    expect(page).to have_content('8 records on all pages: 511, 515, 523, 524, 527, 531, 542, and 551')
  end
end
