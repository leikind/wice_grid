# encoding: utf-8
require 'acceptance_helper'

describe 'CSV export WiceGrid', type: :request, js: true do
  before :each do
    visit '/csv_export'
  end

  it 'should export csv' do
    # no idea how to test these

    # find(:css, 'button.wg-external-csv-export-button').click

    select 'Urgent', from: 'g1_f_priority_id'

    # find(:css, 'button.div.clickable.export-to-csv-button').click
  end
end
