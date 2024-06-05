# encoding: utf-8
require 'acceptance_helper'

describe 'with show_filters: :no as a grid parameter WiceGrid', type: :request, js: true do
  before :each do
    visit '/disable_all_filters'
  end

  it 'does not render filters' do
    expect(page).to have_no_selector('#grid_f_id_fr')
    expect(page).to have_no_selector('#grid_f_id_to')
    expect(page).to have_no_selector('#grid_f_description')
    expect(page).to have_no_selector('#grid_f_created_at_fr_year')
    expect(page).to have_no_selector('#grid_f_created_at_fr_month')

    expect(page).to have_no_selector('#grid_f_created_at_to_year')
    expect(page).to have_no_selector('#grid_f_created_at_to_month')

    expect(page).to have_no_selector('#grid_f_title')
    expect(page).to have_no_selector('#grid_f_archived')
  end
end
