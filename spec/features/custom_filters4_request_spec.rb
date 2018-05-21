# encoding: utf-8
require 'acceptance_helper'

describe 'custom_ordering WiceGrid', type: :request, js: true do
  before :each do
    visit '/custom_filters4'
  end

  it 'should not be possible to expand custom filters' do
    has_css?('.expand-multi-select-icon').should be_false
    has_css?('.collapse-multi-select-icon').should be_false
  end
end
