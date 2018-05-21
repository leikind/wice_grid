# encoding: utf-8
require 'acceptance_helper'

describe 'with_resultset WiceGrid', type: :request, js: true do
  before :each do
    visit '/resultset_processings2'
  end

  it 'should show records displayed on all pages' do
    find(:css, '#process').click
    sleep 1

    within '.example' do
      page.should have_content('50 records on all pages: 540, 519, 507, 537, 531, 551, 515, 511, 524, 542, 523, 527, 518, 535, 539, 520, 532, 512, 514, 522, 546, 516, 521, 544, 543, 550, 552, 510, 541, 553, 529, 508, 513, 528, 556, 548, 547, 525, 534, 555, 549, 536, 545, 509, 517, 538, 526, 554, 530, and 533')
    end
  end

  it 'should show records displayed on all pages with a text filter selection' do
    fill_in('g_f_title', with: 'ed')
    sleep 2
    find(:css, '#process').click
    sleep 1

    within '.example' do
      page.should have_content('2 records on all pages: 507 and 534')
    end
  end

  it 'should show records displayed on all pages with a custom filter selection' do
    select 'Cancelled',  from: 'g_f_status_id'
    sleep 1

    find(:css, '#process').click
    sleep 1

    within '.example' do
      page.should have_content('8 records on all pages: 531, 551, 515, 511, 524, 542, 523, and 527')
    end
  end
end
