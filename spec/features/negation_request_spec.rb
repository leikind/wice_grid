# encoding: utf-8
require 'acceptance_helper'

describe 'negation WiceGrid', type: :request, js: true do
  before :each do
    visit '/negation'
  end

  it 'should negate the semantics of the text  filter' do
    fill_in('grid_f_title_v', with: 'sed')
    select 'no', from: 'grid_f_archived'

    find(:css, '#grid_submit_grid_icon').click

    expect(page).to have_content('sed impedit iste')
    expect(page).to have_no_content('ut ipsum excepturi')

    find(:css, '#grid_f_title_n').click

    find(:css, '#grid_submit_grid_icon').click

    expect(page).to have_no_content('sed impedit iste')
    expect(page).to have_content('ut ipsum excepturi')
  end
end
