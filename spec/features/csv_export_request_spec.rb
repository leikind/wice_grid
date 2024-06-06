# encoding: utf-8
require 'acceptance_helper'

describe 'CSV export WiceGrid', type: :request, js: true do
  before :each do
    visit '/csv_export'
  end

  it 'should export csv' do
    skip "This test should be run with BROWSER=y in environment" unless ENV['BROWSER']
    button = find(:css, 'button.wg-external-csv-export-button')
    button.click
    expect(DownloadHelpers::download_content)
        .to start_with('ID;Title;Priority;Status;Project Name;')
  end
end
