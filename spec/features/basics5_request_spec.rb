# encoding: utf-8
require 'acceptance_helper'

describe 'basisc5 WiceGrid',  js: true do
  before :each do
    visit '/basics5'
  end

  it 'should not be able to order columns with disabled ordering' do
    expect { click_link 'Description' }.to raise_error(Capybara::ElementNotFound)
    expect { click_link 'Archived' }.to raise_error(Capybara::ElementNotFound)
  end
end
