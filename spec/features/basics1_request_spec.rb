# encoding: utf-8
require 'acceptance_helper'

describe 'basisc1 WiceGrid',  js: true do
  before :each do
    visit '/basics1'
  end

  include_examples 'basic task table specs'
  include_examples 'show all and back'
end
