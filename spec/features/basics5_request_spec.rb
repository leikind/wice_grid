# encoding: utf-8
require 'acceptance_helper'

describe 'with allow_ordering: false WiceGrid',  js: true do
  before :each do
    visit '/basics5'
  end

  it 'does not allow to order columns' do
    expect { click_link 'Description' }.to raise_error(Capybara::ElementNotFound)
    expect { click_link 'Archived' }.to raise_error(Capybara::ElementNotFound)
  end
end
