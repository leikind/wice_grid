# encoding: utf-8
require 'acceptance_helper'

describe 'basisc4 WiceGrid',  js: true do
  before :each do
    visit '/basics4'
  end

  it 'should not have disabled filters' do
    expect(page).to have_no_selector('#grid_f_id_fr')
    expect(page).to have_no_selector('#grid_f_id_to')
    expect(page).to have_no_selector('#grid_f_description')
    expect(page).to have_no_selector('#grid_f_created_at_fr_year')
    expect(page).to have_no_selector('#grid_f_created_at_fr_month')

    expect(page).to have_no_selector('#grid_f_created_at_to_year')
    expect(page).to have_no_selector('#grid_f_created_at_to_month')
  end
end
