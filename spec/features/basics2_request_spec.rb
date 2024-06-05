# encoding: utf-8
require 'acceptance_helper'

describe 'with the parameter :name WiceGrid',  js: true do
  before :each do
    visit '/basics2'
  end

  include_examples 'names of columns'
end
