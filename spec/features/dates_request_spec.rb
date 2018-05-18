# encoding: utf-8
require 'acceptance_helper'

describe 'dates WiceGrid', type: :request, js: true do
  before :each do
    visit '/dates'
  end

  include_examples 'sorting Title'
  include_examples 'sorting Archived'
  include_examples 'sorting Due Date'

  include_examples 'sorting Title in all records mode'
  include_examples 'sorting Archived in all records mode'
  include_examples 'sorting Due Date in all records mode'

  include_examples 'Archived filtering'
  include_examples 'Title filtering'

  include_examples 'Due Date datepicker filtering'

  include_examples 'Added datepicker filtering'
  include_examples 'Created At standard filtering'

  it 'should filter by multiple fields' do
    select '2011', from: 'grid_f_updated_at_fr_year'
    select 'January', from: 'grid_f_updated_at_fr_month'
    select '8', from: 'grid_f_updated_at_fr_day'
    select '00', from: 'grid_f_updated_at_fr_hour'
    select '00', from: 'grid_f_updated_at_fr_minute'

    select '2011', from: 'grid_f_updated_at_to_year'
    select 'December', from: 'grid_f_updated_at_to_month'
    select '10', from: 'grid_f_updated_at_to_day'
    select '00', from: 'grid_f_updated_at_to_hour'
    select '00', from: 'grid_f_updated_at_to_minute'

    set_datepicker(self, 'grid_f_created_at_fr_date_placeholder', 2011, 8, 1)

    set_datepicker(self, 'grid_f_created_at_to_date_placeholder', 2011, 8, 30)

    find(:css, '#grid_submit_grid_icon').click

    within '.pagination_status' do
      page.should have_content('1-4 / 4')
    end

    fill_in('grid_f_title', with: 'at')

    find(:css, '#grid_submit_grid_icon').click

    within '.pagination_status' do
      page.should have_content('1-1 / 1')
    end
  end
end
