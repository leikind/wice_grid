# encoding: utf-8
require 'acceptance_helper'

describe 'CSV export WiceGrid', type: :request, js: true do
  before :each do
    visit '/csv_export'
  end

  it 'should export csv' do
    find(:css, 'button.wg-external-csv-export-button').click
    expect(page).to have_content('ID;Title;Priority;Status;Project Name;')
  end
end
