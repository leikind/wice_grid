# encoding: UTF-8
require 'acceptance_helper'

describe 'with the proper use of I18n WiceGrid', type: :request, js: true do
  before :each do
    visit '/localization'
  end

  it 'allows to switch to different languages' do
    click_on('en')
    expect(page).to have_content('show all')

    click_on('nl')
    expect(page).to have_content('Alle rijen tonen')

    click_on('fr')
    expect(page).to have_content('Voir tous')

    click_on('is')
    expect(page).to have_content('Sýna all')

    click_on('en')
  end
end
