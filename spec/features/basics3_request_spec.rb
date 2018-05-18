# encoding: utf-8
require 'acceptance_helper'

describe 'basisc3 WiceGrid',  js: true do
  before :each do
    visit '/basics3'
  end

  include_examples 'sorting ID'
  include_examples 'sorting Title'
  include_examples 'sorting Description'
  include_examples 'sorting Archived'
  include_examples 'sorting Due Date'

  include_examples 'sorting ID in all records mode'
  include_examples 'sorting Title in all records mode'
  include_examples 'sorting Description in all records mode'
  include_examples 'sorting Archived in all records mode'
  include_examples 'sorting Due Date in all records mode'

  include_examples 'Archived filtering'
  include_examples 'Title filtering'

  include_examples 'Due Date datepicker filtering'

  include_examples 'Description filtering'
  include_examples 'ID filtering'
  include_examples 'Description and Title filtering'
end
