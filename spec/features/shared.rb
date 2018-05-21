# encoding: utf-8
shared_examples 'basic task table specs' do
  it 'is present on the page' do
    page.should have_selector('div.wice-grid-container table.wice-grid')
  end

  it 'should have a show all link' do
    within 'div.wice-grid-container table.wice-grid' do
      page.should have_selector('a.wg-show-all-link')
    end
  end

  it 'should change pages' do
    within 'ul.pagination' do
      click_link '2'
    end

    within '.wice-grid li.active' do
      page.should have_content('2')
    end

    within '.pagination_status' do
      page.should have_content('21-40 / 50')
    end

    within 'ul.pagination' do
      click_link '3'
    end

    within '.wice-grid li.active' do
      page.should have_content('3')
    end

    within '.pagination_status' do
      page.should have_content('41-50 / 50')
    end
  end

  it 'should have a pagination status with page 1 as the current page' do
    within 'div.wice-grid-container table.wice-grid' do
      page.should have_selector('div.pagination')

      within 'div.pagination' do
        page.should have_selector('li.active')
        within 'li.active' do
          page.should have_content('1')
        end

        page.should have_content('2')
        page.should have_content('3')
        page.should_not have_content('4')
      end
    end
  end
end

shared_examples 'show all and back' do
  it 'should show all records when asked' do
    click_on 'show all'

    within 'div.wice-grid-container table.wice-grid' do
      page.should have_selector('a.wg-back-to-pagination-link')
    end

    within '.pagination_status' do
      page.should have_content('1-50 / 50')
    end

    click_on 'back to paginated view'

    within '.pagination_status' do
      page.should have_content('1-20 / 50')
    end
  end
end

shared_examples 'names of columns' do
  it 'should have names of columns' do
    within 'div.wice-grid-container table.wice-grid thead' do
      page.should have_content('ID')
      page.should have_content('Title')
      page.should have_content('Description')
      page.should have_content('Archived')
      page.should have_content('Added')
    end
  end
end

shared_examples 'sorting ID' do
  it 'should sort column ID' do
    within 'div.wice-grid-container table.wice-grid thead' do
      click_on 'ID'
    end
    sleep 1

    within 'div.wice-grid-container table.wice-grid thead th.sorted a.desc' do
      page.should have_content('ID')
    end

    within 'div.wice-grid-container table.wice-grid tbody tr:first-child td.sorted' do
      page.should have_content('556')
    end

    within 'div.wice-grid-container table.wice-grid thead' do
      click_on 'ID'
    end
    sleep 1

    within 'div.wice-grid-container table.wice-grid thead th.sorted a.asc' do
      page.should have_content('ID')
    end

    within 'div.wice-grid-container table.wice-grid tbody tr:first-child td.sorted' do
      page.should have_content('507')
    end

    within 'ul.pagination' do
      click_link '2'
    end
    sleep 1

    within '.wice-grid li.active' do
      page.should have_content('2')
    end

    within 'div.wice-grid-container table.wice-grid thead th.sorted a.asc' do
      page.should have_content('ID')
    end

    within 'div.wice-grid-container table.wice-grid tbody tr:first-child td.sorted' do
      page.should have_content('527')
    end
  end
end

shared_examples 'sorting Title' do
  it 'should sort column Title' do
    within 'div.wice-grid-container table.wice-grid thead' do
      click_on 'Title'
    end

    within 'div.wice-grid-container table.wice-grid thead th.sorted a.asc' do
      page.should have_content('Title')
    end

    within 'div.wice-grid-container table.wice-grid tbody tr:first-child td.sorted' do
      page.should have_content('ab')
    end

    within 'div.wice-grid-container table.wice-grid thead' do
      click_on 'Title'
    end

    within 'div.wice-grid-container table.wice-grid thead th.sorted a.desc' do
      page.should have_content('Title')
    end

    within 'div.wice-grid-container table.wice-grid tbody tr:first-child td.sorted' do
      page.should have_content('voluptatum non')
    end

    within 'ul.pagination' do
      click_link '2'
    end

    sleep 1

    within '.wice-grid li.active' do
      page.should have_content('2')
    end

    within 'div.wice-grid-container table.wice-grid thead th.sorted a.desc' do
      page.should have_content('Title')
    end

    within 'div.wice-grid-container table.wice-grid tbody tr:first-child td.sorted' do
      page.should have_content('quia dignissimos maiores')
    end
  end
end

shared_examples 'sorting Description' do
  it 'should sort column Description' do
    within 'div.wice-grid-container table.wice-grid thead' do
      click_on 'Description'
    end

    within 'div.wice-grid-container table.wice-grid thead th.sorted a.asc' do
      page.should have_content('Description')
    end

    within 'div.wice-grid-container table.wice-grid tbody tr:first-child td.sorted' do
      page.should have_content('Accusamus voluptas sunt deleniti iusto dolorem repudiandae.')
    end

    within 'div.wice-grid-container table.wice-grid thead' do
      click_on 'Description'
    end

    within 'div.wice-grid-container table.wice-grid thead th.sorted a.desc' do
      page.should have_content('Description')
    end

    within 'div.wice-grid-container table.wice-grid tbody tr:first-child td.sorted' do
      page.should have_content('Voluptate occaecati quisquam in et qui nostrum eos minus.')
    end

    within 'ul.pagination' do
      click_link '2'
    end

    within '.wice-grid li.active' do
      page.should have_content('2')
    end

    within 'div.wice-grid-container table.wice-grid thead th.sorted a.desc' do
      page.should have_content('Description')
    end

    within 'div.wice-grid-container table.wice-grid tbody tr:first-child td.sorted' do
      page.should have_content('Iure tenetur cum aut optio et quia similique debitis.')
    end
  end
end

shared_examples 'sorting Archived' do
  it 'should sort column Archived' do
    within 'div.wice-grid-container table.wice-grid thead' do
      click_on 'Archived'
    end

    within 'div.wice-grid-container table.wice-grid thead th.sorted a.asc' do
      page.should have_content('Archived')
    end

    within 'div.wice-grid-container table.wice-grid tbody tr:first-child td.sorted' do
      page.should have_content('No')
    end

    within 'div.wice-grid-container table.wice-grid thead' do
      click_on 'Archived'
    end

    within 'div.wice-grid-container table.wice-grid thead th.sorted a.desc' do
      page.should have_content('Archived')
    end

    within 'div.wice-grid-container table.wice-grid tbody tr:first-child td.sorted' do
      page.should have_content('Yes')
    end

    within 'ul.pagination' do
      click_link '2'
    end

    within '.wice-grid li.active' do
      page.should have_content('2')
    end

    within 'div.wice-grid-container table.wice-grid thead th.sorted a.desc' do
      page.should have_content('Archived')
    end

    within 'div.wice-grid-container table.wice-grid tbody tr:first-child td.sorted' do
      page.should have_content('No')
    end
  end
end

shared_examples 'sorting Due Date' do
  it 'should sort column Due Date' do
    within 'div.wice-grid-container table.wice-grid thead' do
      click_on 'Due Date'
    end

    within 'div.wice-grid-container table.wice-grid thead th.sorted a.asc' do
      page.should have_content('Due Date')
    end

    within 'div.wice-grid-container table.wice-grid tbody tr:first-child td.sorted' do
      page.should have_content('2012-06-12')
    end

    within 'div.wice-grid-container table.wice-grid thead' do
      click_on 'Due Date'
    end

    within 'div.wice-grid-container table.wice-grid thead th.sorted a.desc' do
      page.should have_content('Due Date')
    end

    within 'div.wice-grid-container table.wice-grid tbody tr:first-child td.sorted' do
      page.should have_content('2013-03-30')
    end

    within 'ul.pagination' do
      click_link '2'
    end

    within '.wice-grid li.active' do
      page.should have_content('2')
    end

    within 'div.wice-grid-container table.wice-grid thead th.sorted a.desc' do
      page.should have_content('Due Date')
    end

    within 'div.wice-grid-container table.wice-grid tbody tr:first-child td.sorted' do
      page.should have_content('2012-12-13')
    end
  end
end

shared_examples 'sorting ID in all records mode' do
  it 'should sort column ID' do
    click_on 'show all'

    within '.pagination_status' do
      page.should have_content('1-50 / 50')
    end

    within 'div.wice-grid-container table.wice-grid thead' do
      click_on 'ID'
    end

    within 'div.wice-grid-container table.wice-grid thead th.sorted a.desc' do
      page.should have_content('ID')
    end

    within 'div.wice-grid-container table.wice-grid tbody tr:first-child td.sorted' do
      page.should have_content('556')
    end

    within 'div.wice-grid-container table.wice-grid thead' do
      click_on 'ID'
    end

    within 'div.wice-grid-container table.wice-grid thead th.sorted a.asc' do
      page.should have_content('ID')
    end

    within 'div.wice-grid-container table.wice-grid tbody tr:first-child td.sorted' do
      page.should have_content('507')
    end
  end
end

shared_examples 'sorting Title in all records mode' do
  it 'should sort column Title' do
    click_on 'show all'

    within '.pagination_status' do
      page.should have_content('1-50 / 50')
    end

    within 'div.wice-grid-container table.wice-grid thead' do
      click_on 'Title'
    end

    within 'div.wice-grid-container table.wice-grid thead th.sorted a.asc' do
      page.should have_content('Title')
    end

    within 'div.wice-grid-container table.wice-grid tbody tr:first-child td.sorted' do
      page.should have_content('ab')
    end

    within 'div.wice-grid-container table.wice-grid thead' do
      click_on 'Title'
    end

    within 'div.wice-grid-container table.wice-grid thead th.sorted a.desc' do
      page.should have_content('Title')
    end

    within 'div.wice-grid-container table.wice-grid tbody tr:first-child td.sorted' do
      page.should have_content('voluptatum non')
    end
  end
end

shared_examples 'sorting Description in all records mode' do
  it 'should sort column Description' do
    click_on 'show all'

    sleep 1

    within '.pagination_status' do
      page.should have_content('1-50 / 50')
    end

    within 'div.wice-grid-container table.wice-grid thead' do
      click_on 'Description'
    end

    within 'div.wice-grid-container table.wice-grid thead th.sorted a.asc' do
      page.should have_content('Description')
    end

    within 'div.wice-grid-container table.wice-grid tbody tr:first-child td.sorted' do
      page.should have_content('Accusamus voluptas sunt deleniti iusto dolorem repudiandae.')
    end

    within 'div.wice-grid-container table.wice-grid thead' do
      click_on 'Description'
    end

    within 'div.wice-grid-container table.wice-grid thead th.sorted a.desc' do
      page.should have_content('Description')
    end

    within 'div.wice-grid-container table.wice-grid tbody tr:first-child td.sorted' do
      page.should have_content('Voluptate occaecati quisquam in et qui nostrum eos minus.')
    end
  end
end

shared_examples 'sorting Archived in all records mode' do
  it 'should sort column Archived' do
    click_on 'show all'

    within '.pagination_status' do
      page.should have_content('1-50 / 50')
    end

    within 'div.wice-grid-container table.wice-grid thead' do
      click_on 'Archived'
    end

    within 'div.wice-grid-container table.wice-grid thead th.sorted a.asc' do
      page.should have_content('Archived')
    end

    within 'div.wice-grid-container table.wice-grid tbody tr:first-child td.sorted' do
      page.should have_content('No')
    end

    within 'div.wice-grid-container table.wice-grid thead' do
      click_on 'Archived'
    end

    within 'div.wice-grid-container table.wice-grid thead th.sorted a.desc' do
      page.should have_content('Archived')
    end

    within 'div.wice-grid-container table.wice-grid tbody tr:first-child td.sorted' do
      page.should have_content('Yes')
    end
  end
end

shared_examples 'sorting Due Date in all records mode' do
  it 'should sort column Due Date' do
    click_on 'show all'

    within '.pagination_status' do
      page.should have_content('1-50 / 50')
    end

    within 'div.wice-grid-container table.wice-grid thead' do
      click_on 'Due Date'
    end

    within 'div.wice-grid-container table.wice-grid thead th.sorted a.asc' do
      page.should have_content('Due Date')
    end

    within 'div.wice-grid-container table.wice-grid tbody tr:first-child td.sorted' do
      page.should have_content('2012-06-12')
    end

    within 'div.wice-grid-container table.wice-grid thead' do
      click_on 'Due Date'
    end

    within 'div.wice-grid-container table.wice-grid thead th.sorted a.desc' do
      page.should have_content('Due Date')
    end

    within 'div.wice-grid-container table.wice-grid tbody tr:first-child td.sorted' do
      page.should have_content('2013-03-30')
    end
  end
end

def wait_for_ajax(page)
  counter = 0
  while page.execute_script('return $.active').to_i > 0
    counter += 1
    sleep(0.1)
    fail 'AJAX request took longer than 5 seconds.' if counter >= 50
  end
end

MONTH_NAMES = %w(Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec)


def set_datepicker(context, picker, year, month, day)
  context.find(:css, "##{picker} .ui-datepicker-trigger").click

  year_select = context.find(:css, '.ui-datepicker-year')

  year_select.select(year.to_s)

  month_select = context.find(:css, '.ui-datepicker-month')
  month_select.select(MONTH_NAMES[month])

  context.within '.ui-datepicker-calendar' do
    context.click_on(day.to_s)
  end
end

shared_examples 'Due Date datepicker filtering' do
  it 'should filter by Due Date' do
    set_datepicker(self, 'grid_f_due_date_fr_date_placeholder', 2012, 0, 1)

    set_datepicker(self, 'grid_f_due_date_to_date_placeholder', 2013, 0, 1)

    find(:css, '#grid_submit_grid_icon').click
    sleep 1


    within '.pagination_status' do
      page.should have_content('1-20 / 35')
    end

    within 'div.wice-grid-container table.wice-grid tbody tr:first-child td.active-filter' do
      page.should have_content('2012-07-29')
    end

    within 'div.wice-grid-container table.wice-grid thead' do
      click_on 'ID'
    end
    sleep 1

    within '.pagination_status' do
      page.should have_content('1-20 / 35')
    end

    within 'ul.pagination' do
      click_link '2'
    end
    sleep 1

    within 'div.wice-grid-container table.wice-grid tbody tr:first-child td.active-filter' do
      page.should have_content('2012-07-02')
    end

    set_datepicker(self, 'grid_f_due_date_fr_date_placeholder', 2012, 6, 28)

    set_datepicker(self, 'grid_f_due_date_to_date_placeholder', 2012, 6, 31)

    find(:css, '#grid_submit_grid_icon').click
    sleep 1

    within '.pagination_status' do
      page.should have_content('1-1 / 1')
    end

    find(:css, '#grid_f_due_date_fr_date_view').click
    sleep 1

    find(:css, '#grid_submit_grid_icon').click
    sleep 1

    within '.pagination_status' do
      page.should have_content('1-10 / 10')
    end

    find(:css, '#grid_f_due_date_to_date_view').click
    sleep 1

    find(:css, '#grid_submit_grid_icon').click
    sleep 1

    within '.pagination_status' do
      page.should have_content('1-20 / 50')
    end
  end
end

shared_examples 'Added datepicker filtering' do
  it 'should filter by Added' do
    set_datepicker(self, 'grid_f_created_at_fr_date_placeholder', 2011, 5, 1)

    set_datepicker(self, 'grid_f_created_at_to_date_placeholder', 2011, 9, 1)

    find(:css, '#grid_submit_grid_icon').click
    sleep 1

    within '.pagination_status' do
      page.should have_content('1-20 / 29')
    end

    within 'div.wice-grid-container table.wice-grid tbody tr:first-child td.active-filter' do
      page.should have_content('2011-09-13 22:11:12')
    end

    within 'div.wice-grid-container table.wice-grid thead' do
      click_on 'ID'
    end
    sleep 1

    within '.pagination_status' do
      page.should have_content('1-20 / 29')
    end

    within 'ul.pagination' do
      click_link '2'
    end
    sleep 2

    within 'div.wice-grid-container table.wice-grid tbody tr:first-child td.active-filter' do
      page.should have_content('2011-09-22 22:11:12')
      # page.should have_content('2011-08-14 22:11:12')
    end

    find(:css, '#grid_reset_grid_icon').click
    sleep 1

    within '.pagination_status' do
      page.should have_content('1-20 / 50')
    end
  end
end

# !!!
shared_examples 'Due Date standard filtering' do
  it 'should filter by Due Date (standard filter)' do
    select '2011', from: 'grid_f_created_at_fr_year'
    select 'February', from: 'grid_f_created_at_fr_month'
    select '8', from: 'grid_f_created_at_fr_day'
    select '00', from: 'grid_f_created_at_fr_hour'
    select '00', from: 'grid_f_created_at_fr_minute'

    select '2011', from: 'grid_f_created_at_to_year'
    select 'September', from: 'grid_f_created_at_to_month'
    select '10', from: 'grid_f_created_at_to_day'
    select '00', from: 'grid_f_created_at_to_hour'
    select '00', from: 'grid_f_created_at_to_minute'

    find(:css, '#grid_submit_grid_icon').click

    within '.pagination_status' do
      page.should have_content('1-16 / 16')
    end

    within 'div.wice-grid-container table.wice-grid tbody tr:first-child td.active-filter' do
      page.should have_content('13 Aug 22:11')
    end

    within 'div.wice-grid-container table.wice-grid thead' do
      click_on 'ID'
    end

    within '.pagination_status' do
      page.should have_content('1-16 / 16')
    end

    find(:css, '#grid_reset_grid_icon').click
    within '.pagination_status' do
      page.should have_content('1-20 / 50')
    end
  end
end

shared_examples 'Created At standard filtering' do
  it 'should filter by created_at' do
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

    find(:css, '#grid_submit_grid_icon').click
    sleep 1

    within '.pagination_status' do
      page.should have_content('1-14 / 14')
    end

    within 'div.wice-grid-container table.wice-grid tbody tr:first-child td.active-filter' do
      page.should have_content('2011-11-26 22:11:12')
    end

    within 'div.wice-grid-container table.wice-grid thead' do
      click_on 'ID'
    end
    sleep 1

    within '.pagination_status' do
      page.should have_content('1-14 / 14')
    end

    find(:css, '#grid_reset_grid_icon').click
    sleep 1

    within '.pagination_status' do
      page.should have_content('1-20 / 50')
    end
  end
end

shared_examples 'Description filtering' do
  it 'should filter by Description' do
    fill_in('grid_f_description', with: 've')

    find(:css, '#grid_submit_grid_icon').click

    within '.pagination_status' do
      page.should have_content('1-12 / 12')
    end

    within 'div.wice-grid-container table.wice-grid tbody tr:first-child td.active-filter' do
      page.should have_content('Velit atque sapiente aspernatur sint fuga.')
    end

    page.should have_content('Vero sit voluptate sed tempora et provident sequi nihil.')

    within 'div.wice-grid-container table.wice-grid thead' do
      click_on 'Description'
    end

    within '.pagination_status' do
      page.should have_content('1-12 / 12')
    end

    within 'div.wice-grid-container table.wice-grid tbody tr:first-child td.active-filter' do
      page.should have_content('Ad sunt vel maxime labore temporibus incidunt quidem.')
    end

    page.should have_content('Adipisci voluptate sed esse velit.')

    within 'div.wice-grid-container table.wice-grid thead' do
      click_on 'ID'
    end

    within '.pagination_status' do
      page.should have_content('1-12 / 12')
    end

    page.should have_content('Adipisci voluptate sed esse velit.')
    page.should have_content('Ad sunt vel maxime labore temporibus incidunt quidem.')

    find(:css, '#grid_reset_grid_icon').click
    within '.pagination_status' do
      page.should have_content('1-20 / 50')
    end
  end
end

shared_examples 'ID filtering' do
  it 'should filter by ID, one limit' do
    fill_in('grid_f_id_eq', with: 550)

    find(:css, '#grid_submit_grid_icon').click

    within '.pagination_status' do
      page.should have_content('1-1 / 1')
    end

    within 'div.wice-grid-container table.wice-grid tbody tr:first-child td.active-filter' do
      page.should have_content('550')
    end
  end
end

shared_examples 'ID filtering, range' do
  it 'should filter by ID, one limit' do
    fill_in('grid_f_id_fr', with: 550)

    find(:css, '#grid_submit_grid_icon').click

    within '.pagination_status' do
      page.should have_content('1-7 / 7')
    end

    within 'div.wice-grid-container table.wice-grid tbody tr:first-child td.active-filter' do
      page.should have_content('550')
    end

    551.upto(556) do |i|
      page.should have_content(i)
    end

    within 'div.wice-grid-container table.wice-grid thead' do
      click_on 'ID'
    end

    within '.pagination_status' do
      page.should have_content('1-7 / 7')
    end

    within 'div.wice-grid-container table.wice-grid tbody tr:first-child td.sorted.active-filter' do
      page.should have_content('550')
    end

    551.upto(556) do |i|
      page.should have_content(i)
    end

    within 'div.wice-grid-container table.wice-grid thead' do
      click_on 'ID'
    end

    within '.pagination_status' do
      page.should have_content('1-7 / 7')
    end

    within 'div.wice-grid-container table.wice-grid tbody tr:first-child td.sorted' do
      page.should have_content('556')
    end

    within 'div.wice-grid-container table.wice-grid thead' do
      click_on 'Title'
    end

    within '.pagination_status' do
      page.should have_content('1-7 / 7')
    end

    550.upto(556) do |i|
      page.should have_content(i)
    end

    find(:css, '#grid_reset_grid_icon').click
    within '.pagination_status' do
      page.should have_content('1-20 / 50')
    end
  end
end

shared_examples 'ID two limits filtering' do
  it 'should filter by ID, two limits' do
    fill_in('grid_f_id_fr', with: 507)
    fill_in('grid_f_id_to', with: 509)

    find(:css, '#grid_submit_grid_icon').click

    within '.pagination_status' do
      page.should have_content('1-3 / 3')
    end

    within 'div.wice-grid-container table.wice-grid tbody tr:first-child td.active-filter' do
      page.should have_content('507')
    end

    page.should have_content('508')
    page.should have_content('509')

    within 'div.wice-grid-container table.wice-grid thead' do
      click_on 'ID'
    end

    within '.pagination_status' do
      page.should have_content('1-3 / 3')
    end

    within 'div.wice-grid-container table.wice-grid tbody tr:first-child td.sorted.active-filter' do
      page.should have_content('507')
    end

    page.should have_content('508')
    page.should have_content('509')

    within 'div.wice-grid-container table.wice-grid thead' do
      click_on 'ID'
    end

    within '.pagination_status' do
      page.should have_content('1-3 / 3')
    end

    within 'div.wice-grid-container table.wice-grid tbody tr:first-child td.sorted' do
      page.should have_content('509')
    end

    within 'div.wice-grid-container table.wice-grid thead' do
      click_on 'Title'
    end

    within '.pagination_status' do
      page.should have_content('1-3 / 3')
    end

    page.should have_content('507')
    page.should have_content('508')
    page.should have_content('509')

    find(:css, '#grid_reset_grid_icon').click
    within '.pagination_status' do
      page.should have_content('1-20 / 50')
    end
  end
end

shared_examples 'Description and Title filtering' do
  it 'should filter by multiple columns' do
    fill_in('grid_f_description', with: 'v')
    fill_in('grid_f_title', with: 's')
    select 'no', from: 'grid_f_archived'

    find(:css, '#grid_submit_grid_icon').click

    within '.pagination_status' do
      page.should have_content('1-11 / 11')
    end

    page.should have_content('Inventore iure eos labore ipsum.')
    page.should have_content('Velit atque sapiente aspernatur sint fuga.')

    within 'div.wice-grid-container table.wice-grid thead' do
      click_on 'Description'
    end

    within '.pagination_status' do
      page.should have_content('1-11 / 11')
    end

    page.should have_content('Inventore iure eos labore ipsum.')
    page.should have_content('Velit atque sapiente aspernatur sint fuga.')

    find(:css, '#grid_reset_grid_icon').click
    within '.pagination_status' do
      page.should have_content('1-20 / 50')
    end
  end
end

shared_examples 'Archived filtering' do
  it 'should filter by Archived' do
    select 'yes', from: 'grid_f_archived'
    find(:css, '#grid_submit_grid_icon').click

    within '.pagination_status' do
      page.should have_content('1-4 / 4')
    end

    within first(:css, 'td.active-filter') do
      page.should have_content('Yes')
    end

    select 'no', from: 'grid_f_archived'
    find(:css, '#grid_submit_grid_icon').click

    within '.pagination_status' do
      page.should have_content('1-20 / 46')
    end

    within first(:css, 'td.active-filter') do
      page.should have_content('No')
    end

    within 'ul.pagination' do
      click_link '2'
    end

    within '.pagination_status' do
      page.should have_content('21-40 / 46')
    end

    within(first(:css, 'td.active-filter')) do
      page.should have_content('No')
    end

    find(:css, '#grid_reset_grid_icon').click
    within '.pagination_status' do
      page.should have_content('1-20 / 50')
    end
  end
end

shared_examples 'Title filtering' do
  it 'should filter by Ttile' do
    fill_in('grid_f_title', with: 'ed')

    find(:css, '#grid_submit_grid_icon').click

    within '.pagination_status' do
      page.should have_content('1-2 / 2')
    end

    within 'div.wice-grid-container table.wice-grid tbody tr:first-child td.active-filter' do
      page.should have_content('sed impedit iste')
    end

    page.should have_content('corporis expedita vel')

    within 'div.wice-grid-container table.wice-grid thead' do
      click_on 'Title'
    end

    within '.pagination_status' do
      page.should have_content('1-2 / 2')
    end

    within 'div.wice-grid-container table.wice-grid tbody tr:first-child td.active-filter' do
      page.should have_content('corporis expedita vel')
    end

    page.should have_content('sed impedit iste')

    within 'div.wice-grid-container table.wice-grid thead' do
      click_on 'ID'
    end

    within '.pagination_status' do
      page.should have_content('1-2 / 2')
    end

    page.should have_content('corporis expedita vel')
    page.should have_content('sed impedit iste')

    find(:css, '#grid_reset_grid_icon').click
    within '.pagination_status' do
      page.should have_content('1-20 / 50')
    end
  end
end
