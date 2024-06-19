# encoding: utf-8
require 'acceptance_helper'

describe 'On the page /basics1 the most simple WiceGrid',  js: true do
  before :each do
    visit '/basics1'
  end

  include_examples 'basic task table specs'
  include_examples 'show all and back'
end
