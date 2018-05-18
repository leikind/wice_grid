# encoding: utf-8
require 'acceptance_helper'

describe 'no_records WiceGrid', type: :request, js: true do
  before :each do
    visit '/no_records'
  end

  it 'should contain a No Records block for example 1' do
    within '.example1' do
      page.should have_content('No records found')
    end
  end

  it 'should contain a No Records block for example 2' do
    within '.example2' do
      page.should have_content('No records found')
    end
  end

  it 'should contain a No Records block for example 3' do
    within '.example3' do
      page.should have_content('No records found')
    end
  end
end
