# encoding: utf-8
require 'acceptance_helper'

describe 'On the page /adding_rows WiceGrid', type: :request, js: true do
  before :each do
    visit '/adding_rows'
  end

  it 'allows to filter the rows with the help of a custom filter renered as <select>' do
    select 'Urgent', from: 'grid_f_priority_id'

    find(:css, '#grid_submit_grid_icon').click

    ['inventore architecto aut', 'veniam tempora', 'doloremque', 'qui animi', 'dolor et corporis'].each do |title|
      expect(page).to have_content(title)
      expect(page).to have_content("Panic! \"#{title}\"")
    end

    expect(page).to have_content("Don't panic")
  end
end
