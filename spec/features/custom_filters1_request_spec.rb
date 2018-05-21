# encoding: utf-8
require 'acceptance_helper'

describe 'custom_ordering WiceGrid', type: :request, js: true do
  before :each do
    visit '/custom_filters1'
  end

  it 'should have all options' do
    within '#g1_f_status' do
      page.should have_content('Development')
      page.should have_content('Testing')
      page.should have_content('Production')
    end

    within '#g2_f_status' do
      page.should have_content('Development')
      page.should have_content('Testing')
      page.should have_content('Production')
    end

    within '#g3_f_status' do
      page.should have_content('development')
      page.should have_content('testing')
      page.should have_content('production')
    end

    within '#g4_f_status' do
      page.should have_content('development')
      page.should have_content('testing')
      page.should have_content('production')
    end
  end

  it 'should have expand/collapse' do
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

  it 'should filter by custom filter' do
    select 'Development', from: 'g1_f_status'
    find(:css, '#g1_submit_grid_icon').click

    select 'Development', from: 'g2_f_status'
    find(:css, '#g2_submit_grid_icon').click

    select 'development', from: 'g3_f_status'
    find(:css, '#g3_submit_grid_icon').click

    select 'development', from: 'g4_f_status'
    find(:css, '#g4_submit_grid_icon').click

    within '#g1 .pagination_status' do
      page.should have_content('1-3 / 3')
    end

    within '#g2 .pagination_status' do
      page.should have_content('1-3 / 3')
    end

    within '#g3 .pagination_status' do
      page.should have_content('1-3 / 3')
    end

    within '#g4 .pagination_status' do
      page.should have_content('1-3 / 3')
    end
  end

  it 'should filter by custom filter with multiselect' do
    find(:css, '#g1 .expand-multi-select-icon').click

    select('Testing', from: 'g1_f_status')
    select('Production', from: 'g1_f_status')

    find(:css, '#g1_submit_grid_icon').click

    within '#g1 .pagination_status' do
      page.should have_content('1-5 / 8')
    end

    ###
    find(:css, '#g2 .expand-multi-select-icon').click

    select('Testing', from: 'g2_f_status')
    select('Production', from: 'g2_f_status')

    find(:css, '#g2_submit_grid_icon').click

    within '#g2 .pagination_status' do
      page.should have_content('1-5 / 8')
    end

    ###
    find(:css, '#g3 .expand-multi-select-icon').click

    select('testing', from: 'g3_f_status')
    select('production', from: 'g3_f_status')

    find(:css, '#g3_submit_grid_icon').click

    within '#g3 .pagination_status' do
      page.should have_content('1-5 / 8')
    end

    ###
    find(:css, '#g4 .expand-multi-select-icon').click

    select('testing', from: 'g4_f_status')
    select('production', from: 'g4_f_status')

    find(:css, '#g4_submit_grid_icon').click

    within '#g4 .pagination_status' do
      page.should have_content('1-5 / 8')
    end

    ##

    find(:css, '#g1 .collapse-multi-select-icon').click
    select 'Testing', from: 'g1_f_status'
    find(:css, '#g1_submit_grid_icon').click
    within '#g1 .pagination_status' do
      page.should have_content('1-3 / 3')
    end

    find(:css, '#g2 .collapse-multi-select-icon').click
    select 'Testing', from: 'g2_f_status'
    find(:css, '#g2_submit_grid_icon').click
    within '#g2 .pagination_status' do
      page.should have_content('1-3 / 3')
    end

    find(:css, '#g3 .collapse-multi-select-icon').click
    select 'testing', from: 'g3_f_status'
    find(:css, '#g3_submit_grid_icon').click
    within '#g3 .pagination_status' do
      page.should have_content('1-3 / 3')
    end

    find(:css, '#g4 .collapse-multi-select-icon').click
    select 'testing', from: 'g4_f_status'
    find(:css, '#g4_submit_grid_icon').click
    within '#g4 .pagination_status' do
      page.should have_content('1-3 / 3')
    end
  end
end
