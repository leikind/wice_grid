# encoding: utf-8
require 'acceptance_helper'

describe 'On the page /custom_filters1 with one table and custom filters WiceGrid', type: :feature, js: true do
  before :each do
    visit '/custom_filters1'
  end

  it 'shows all options' do
    expect(page).to have_select('g1_f_status', options: %w(-- Development Testing Production))
    expect(page).to have_select('g2_f_status', options: %w(-- Development Testing Production))
    expect(page).to have_select('g3_f_status', options: %w(-- development testing production))
    expect(page).to have_select('g4_f_status', options: %w(-- development testing production))
  end

  it 'allows to expand/collapse' do
    find(:css, '#g1 .expand-multi-select-icon').click
    find(:css, '#g1 .collapse-multi-select-icon').click
    find(:css, '#g1 .expand-multi-select-icon').click

    find(:css, '#g2 .expand-multi-select-icon').click
    find(:css, '#g2 .collapse-multi-select-icon').click
    find(:css, '#g2 .expand-multi-select-icon').click

    find(:css, '#g3 .expand-multi-select-icon').click
    find(:css, '#g3 .collapse-multi-select-icon').click
    find(:css, '#g3 .expand-multi-select-icon').click

    find(:css, '#g4 .expand-multi-select-icon').click
    find(:css, '#g4 .collapse-multi-select-icon').click
    find(:css, '#g4 .expand-multi-select-icon').click
  end

  it 'allows to filter by custom filter' do
    select 'Development', from: 'g1_f_status'
    find(:css, '#g1_submit_grid_icon').click
    expect(page).to have_selector('#g1 .pagination_status', text: '1-3 / 3')

    select 'Development', from: 'g2_f_status'
    find(:css, '#g2_submit_grid_icon').click
    expect(page).to have_selector('#g1 .pagination_status', text: '1-3 / 3')
    expect(page).to have_selector('#g2 .pagination_status', text: '1-3 / 3')

    select 'development', from: 'g3_f_status'
    find(:css, '#g3_submit_grid_icon').click
    expect(page).to have_selector('#g1 .pagination_status', text: '1-3 / 3')
    expect(page).to have_selector('#g2 .pagination_status', text: '1-3 / 3')
    expect(page).to have_selector('#g3 .pagination_status', text: '1-3 / 3')

    select 'development', from: 'g4_f_status'
    find(:css, '#g4_submit_grid_icon').click
    expect(page).to have_selector('#g1 .pagination_status', text: '1-3 / 3')
    expect(page).to have_selector('#g2 .pagination_status', text: '1-3 / 3')
    expect(page).to have_selector('#g3 .pagination_status', text: '1-3 / 3')
    expect(page).to have_selector('#g4 .pagination_status', text: '1-3 / 3')
  end

  it 'allows to filter by custom filter with multiselect' do
    find(:css, '#g1 .expand-multi-select-icon').click

    select('Testing', from: 'g1_f_status')
    select('Production', from: 'g1_f_status')

    find(:css, '#g1_submit_grid_icon').click

    within '#g1 .pagination_status' do
      expect(page).to have_content('1-5 / 8')
    end

    ###
    find(:css, '#g2 .expand-multi-select-icon').click

    select('Testing', from: 'g2_f_status')
    select('Production', from: 'g2_f_status')

    find(:css, '#g2_submit_grid_icon').click

    within '#g2 .pagination_status' do
      expect(page).to have_content('1-5 / 8')
    end

    ###
    find(:css, '#g3 .expand-multi-select-icon').click

    select('testing', from: 'g3_f_status')
    select('production', from: 'g3_f_status')

    find(:css, '#g3_submit_grid_icon').click

    within '#g3 .pagination_status' do
      expect(page).to have_content('1-5 / 8')
    end

    ###
    find(:css, '#g4 .expand-multi-select-icon').click

    select('testing', from: 'g4_f_status')
    select('production', from: 'g4_f_status')

    find(:css, '#g4_submit_grid_icon').click

    within '#g4 .pagination_status' do
      expect(page).to have_content('1-5 / 8')
    end

    ##

    find(:css, '#g1 .collapse-multi-select-icon').click
    select 'Testing', from: 'g1_f_status'
    find(:css, '#g1_submit_grid_icon').click
    within '#g1 .pagination_status' do
      expect(page).to have_content('1-3 / 3')
    end

    find(:css, '#g2 .collapse-multi-select-icon').click
    select 'Testing', from: 'g2_f_status'
    find(:css, '#g2_submit_grid_icon').click
    within '#g2 .pagination_status' do
      expect(page).to have_content('1-3 / 3')
    end

    find(:css, '#g3 .collapse-multi-select-icon').click
    select 'testing', from: 'g3_f_status'
    find(:css, '#g3_submit_grid_icon').click
    within '#g3 .pagination_status' do
      expect(page).to have_content('1-3 / 3')
    end

    find(:css, '#g4 .collapse-multi-select-icon').click
    select 'testing', from: 'g4_f_status'
    find(:css, '#g4_submit_grid_icon').click
    within '#g4 .pagination_status' do
      expect(page).to have_content('1-3 / 3')
    end
  end
end
