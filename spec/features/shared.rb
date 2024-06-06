# encoding: utf-8
shared_examples 'basic task table specs' do
  it 'is present on the page' do
    expect(page).to have_selector('div.wice-grid-container table.wice-grid')
  end

  it 'should have a show all link' do
    within 'div.wice-grid-container table.wice-grid' do
      expect(page).to have_selector('a.wg-show-all-link')
    end
  end

  it 'should change pages' do
    within 'ul.pagination' do
      click_link '2'
    end

    within '.wice-grid li.active' do
      expect(page).to have_content('2')
    end

    within '.pagination_status' do
      expect(page).to have_content('21-40 / 50')
    end

    within 'ul.pagination' do
      click_link '3'
    end

    within '.wice-grid li.active' do
      expect(page).to have_content('3')
    end

    within '.pagination_status' do
      expect(page).to have_content('41-50 / 50')
    end
  end

  it 'should have a pagination status with page 1 as the current page' do
    within 'div.wice-grid-container table.wice-grid' do
      expect(page).to have_selector('div.pagination')

      within 'div.pagination' do
        expect(page).to have_selector('li.active')
        within 'li.active' do
          expect(page).to have_content('1')
        end

        expect(page).to have_content('2')
        expect(page).to have_content('3')
        expect(page).to have_no_content('4')
      end
    end
  end
end

shared_examples 'show all and back' do
  it 'should show all records when asked' do
    click_on 'show all'

    within 'div.wice-grid-container table.wice-grid' do
      expect(page).to have_selector('a.wg-back-to-pagination-link')
    end

    within '.pagination_status' do
      expect(page).to have_content('1-50 / 50')
    end

    click_on 'back to paginated view'

    within '.pagination_status' do
      expect(page).to have_content('1-20 / 50')
    end
  end
end

shared_examples 'names of columns' do
  it 'should have names of columns' do
    within 'div.wice-grid-container table.wice-grid thead' do
      expect(page).to have_content('ID')
      expect(page).to have_content('Title')
      expect(page).to have_content('Description')
      expect(page).to have_content('Archived')
      expect(page).to have_content('Added')
    end
  end
end

shared_examples 'sorting ID' do
  it 'should sort column ID' do
    within 'div.wice-grid-container table.wice-grid thead' do
      click_on 'ID'
    end

    within 'div.wice-grid-container table.wice-grid thead th.sorted a.desc' do
      expect(page).to have_content('ID')
    end

    within 'div.wice-grid-container table.wice-grid tbody tr:first-child td.sorted' do
      expect(page).to have_content('556')
    end

    within 'div.wice-grid-container table.wice-grid thead' do
      click_on 'ID'
    end

    within 'div.wice-grid-container table.wice-grid thead th.sorted a.asc' do
      expect(page).to have_content('ID')
    end

    within 'div.wice-grid-container table.wice-grid tbody tr:first-child td.sorted' do
      expect(page).to have_content('507')
    end

    within 'ul.pagination' do
      click_link '2'
    end

    within '.wice-grid li.active' do
      expect(page).to have_content('2')
    end

    within 'div.wice-grid-container table.wice-grid thead th.sorted a.asc' do
      expect(page).to have_content('ID')
    end

    within 'div.wice-grid-container table.wice-grid tbody tr:first-child td.sorted' do
      expect(page).to have_content('527')
    end
  end
end

shared_examples 'sorting Title' do
  it 'should sort column Title' do
    within 'div.wice-grid-container table.wice-grid thead' do
      click_on 'Title'
    end

    within 'div.wice-grid-container table.wice-grid thead th.sorted a.asc' do
      expect(page).to have_content('Title')
    end

    within 'div.wice-grid-container table.wice-grid tbody tr:first-child td.sorted' do
      expect(page).to have_content('ab')
    end

    within 'div.wice-grid-container table.wice-grid thead' do
      click_on 'Title'
    end

    within 'div.wice-grid-container table.wice-grid thead th.sorted a.desc' do
      expect(page).to have_content('Title')
    end

    within 'div.wice-grid-container table.wice-grid tbody tr:first-child td.sorted' do
      expect(page).to have_content('voluptatum non')
    end

    within 'ul.pagination' do
      click_link '2'
    end

    within '.wice-grid li.active' do
      expect(page).to have_content('2')
    end

    within 'div.wice-grid-container table.wice-grid thead th.sorted a.desc' do
      expect(page).to have_content('Title')
    end

    within 'div.wice-grid-container table.wice-grid tbody tr:first-child td.sorted' do
      expect(page).to have_content('quia dignissimos maiores')
    end
  end
end

shared_examples 'sorting Description' do
  it 'should sort column Description' do
    within 'div.wice-grid-container table.wice-grid thead' do
      click_on 'Description'
    end

    within 'div.wice-grid-container table.wice-grid thead th.sorted a.asc' do
      expect(page).to have_content('Description')
    end

    within 'div.wice-grid-container table.wice-grid tbody tr:first-child td.sorted' do
      expect(page).to have_content('Accusamus voluptas sunt deleniti iusto dolorem repudiandae.')
    end

    within 'div.wice-grid-container table.wice-grid thead' do
      click_on 'Description'
    end

    within 'div.wice-grid-container table.wice-grid thead th.sorted a.desc' do
      expect(page).to have_content('Description')
    end

    within 'div.wice-grid-container table.wice-grid tbody tr:first-child td.sorted' do
      expect(page).to have_content('Voluptate occaecati quisquam in et qui nostrum eos minus.')
    end

    within 'ul.pagination' do
      click_link '2'
    end

    within '.wice-grid li.active' do
      expect(page).to have_content('2')
    end

    within 'div.wice-grid-container table.wice-grid thead th.sorted a.desc' do
      expect(page).to have_content('Description')
    end

    within 'div.wice-grid-container table.wice-grid tbody tr:first-child td.sorted' do
      expect(page).to have_content('Iure tenetur cum aut optio et quia similique debitis.')
    end
  end
end

shared_examples 'sorting Archived' do
  it 'should sort column Archived' do
    within 'div.wice-grid-container table.wice-grid thead' do
      click_on 'Archived'
    end

    within 'div.wice-grid-container table.wice-grid thead th.sorted a.asc' do
      expect(page).to have_content('Archived')
    end

    within 'div.wice-grid-container table.wice-grid tbody tr:first-child td.sorted' do
      expect(page).to have_content('No')
    end

    within 'div.wice-grid-container table.wice-grid thead' do
      click_on 'Archived'
    end

    within 'div.wice-grid-container table.wice-grid thead th.sorted a.desc' do
      expect(page).to have_content('Archived')
    end

    within 'div.wice-grid-container table.wice-grid tbody tr:first-child td.sorted' do
      expect(page).to have_content('Yes')
    end

    within 'ul.pagination' do
      click_link '2'
    end

    within '.wice-grid li.active' do
      expect(page).to have_content('2')
    end

    within 'div.wice-grid-container table.wice-grid thead th.sorted a.desc' do
      expect(page).to have_content('Archived')
    end

    within 'div.wice-grid-container table.wice-grid tbody tr:first-child td.sorted' do
      expect(page).to have_content('No')
    end
  end
end

shared_examples 'sorting Due Date' do
  it 'should sort column Due Date' do
    within 'div.wice-grid-container table.wice-grid thead' do
      click_on 'Due Date'
    end

    within 'div.wice-grid-container table.wice-grid thead th.sorted a.asc' do
      expect(page).to have_content('Due Date')
    end

    within 'div.wice-grid-container table.wice-grid tbody tr:first-child td.sorted' do
      expect(page).to have_content('2022-06-12')
    end

    within 'div.wice-grid-container table.wice-grid thead' do
      click_on 'Due Date'
    end

    within 'div.wice-grid-container table.wice-grid thead th.sorted a.desc' do
      expect(page).to have_content('Due Date')
    end

    within 'div.wice-grid-container table.wice-grid tbody tr:first-child td.sorted' do
      expect(page).to have_content('2023-03-30')
    end

    within 'ul.pagination' do
      click_link '2'
    end

    within '.wice-grid li.active' do
      expect(page).to have_content('2')
    end

    within 'div.wice-grid-container table.wice-grid thead th.sorted a.desc' do
      expect(page).to have_content('Due Date')
    end

    within 'div.wice-grid-container table.wice-grid tbody tr:first-child td.sorted' do
      expect(page).to have_content('2022-12-13')
    end
  end
end

shared_examples 'sorting ID in all records mode' do
  it 'should sort column ID' do
    click_on 'show all'

    within '.pagination_status' do
      expect(page).to have_content('1-50 / 50')
    end

    within 'div.wice-grid-container table.wice-grid thead' do
      click_on 'ID'
    end

    within 'div.wice-grid-container table.wice-grid thead th.sorted a.desc' do
      expect(page).to have_content('ID')
    end

    within 'div.wice-grid-container table.wice-grid tbody tr:first-child td.sorted' do
      expect(page).to have_content('556')
    end

    within 'div.wice-grid-container table.wice-grid thead' do
      click_on 'ID'
    end

    within 'div.wice-grid-container table.wice-grid thead th.sorted a.asc' do
      expect(page).to have_content('ID')
    end

    within 'div.wice-grid-container table.wice-grid tbody tr:first-child td.sorted' do
      expect(page).to have_content('507')
    end
  end
end

shared_examples 'sorting Title in all records mode' do
  it 'should sort column Title' do
    click_on 'show all'

    within '.pagination_status' do
      expect(page).to have_content('1-50 / 50')
    end

    within 'div.wice-grid-container table.wice-grid thead' do
      click_on 'Title'
    end

    within 'div.wice-grid-container table.wice-grid thead th.sorted a.asc' do
      expect(page).to have_content('Title')
    end

    within 'div.wice-grid-container table.wice-grid tbody tr:first-child td.sorted' do
      expect(page).to have_content('ab')
    end

    within 'div.wice-grid-container table.wice-grid thead' do
      click_on 'Title'
    end

    within 'div.wice-grid-container table.wice-grid thead th.sorted a.desc' do
      expect(page).to have_content('Title')
    end

    within 'div.wice-grid-container table.wice-grid tbody tr:first-child td.sorted' do
      expect(page).to have_content('voluptatum non')
    end
  end
end

shared_examples 'sorting Description in all records mode' do
  it 'should sort column Description' do
    click_on 'show all'

    within '.pagination_status' do
      expect(page).to have_content('1-50 / 50')
    end

    within 'div.wice-grid-container table.wice-grid thead' do
      click_on 'Description'
    end

    within 'div.wice-grid-container table.wice-grid thead th.sorted a.asc' do
      expect(page).to have_content('Description')
    end

    within 'div.wice-grid-container table.wice-grid tbody tr:first-child td.sorted' do
      expect(page).to have_content('Accusamus voluptas sunt deleniti iusto dolorem repudiandae.')
    end

    within 'div.wice-grid-container table.wice-grid thead' do
      click_on 'Description'
    end

    within 'div.wice-grid-container table.wice-grid thead th.sorted a.desc' do
      expect(page).to have_content('Description')
    end

    within 'div.wice-grid-container table.wice-grid tbody tr:first-child td.sorted' do
      expect(page).to have_content('Voluptate occaecati quisquam in et qui nostrum eos minus.')
    end
  end
end

shared_examples 'sorting Archived in all records mode' do
  it 'should sort column Archived' do
    click_on 'show all'

    within '.pagination_status' do
      expect(page).to have_content('back to paginated view')
      expect(page).to have_content('1-50 / 50')
    end

    within 'div.wice-grid-container table.wice-grid thead' do
      click_on 'Archived'
    end

    within 'div.wice-grid-container table.wice-grid thead th.sorted a.asc' do
      expect(page).to have_content('Archived')
    end

    within 'div.wice-grid-container table.wice-grid tbody tr:first-child td.sorted' do
      expect(page).to have_content('No')
    end

    within 'div.wice-grid-container table.wice-grid thead' do
      click_on 'Archived'
    end

    within 'div.wice-grid-container table.wice-grid thead th.sorted a.desc' do
      expect(page).to have_content('Archived')
    end

    within 'div.wice-grid-container table.wice-grid tbody tr:first-child td.sorted' do
      expect(page).to have_content('Yes')
    end
  end
end

shared_examples 'sorting Due Date in all records mode' do
  it 'should sort column Due Date' do
    click_on 'show all'

    within '.pagination_status' do
      expect(page).to have_content('1-50 / 50')
    end

    within 'div.wice-grid-container table.wice-grid thead' do
      click_on 'Due Date'
    end

    within 'div.wice-grid-container table.wice-grid thead th.sorted a.asc' do
      expect(page).to have_content('Due Date')
    end

    within 'div.wice-grid-container table.wice-grid tbody tr:first-child td.sorted' do
      expect(page).to have_content('2022-06-12')
    end

    within 'div.wice-grid-container table.wice-grid thead' do
      click_on 'Due Date'
    end

    within 'div.wice-grid-container table.wice-grid thead th.sorted a.desc' do
      expect(page).to have_content('Due Date')
    end

    within 'div.wice-grid-container table.wice-grid tbody tr:first-child td.sorted' do
      expect(page).to have_content('2023-03-30')
    end
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
    set_datepicker(self, 'grid_f_due_date_fr_date_placeholder', 2022, 0, 1)

    set_datepicker(self, 'grid_f_due_date_to_date_placeholder', 2023, 0, 1)

    find(:css, '#grid_submit_grid_icon').click

    within '.pagination_status' do
      expect(page).to have_content('1-20 / 35')
    end

    within 'div.wice-grid-container table.wice-grid tbody tr:first-child td.active-filter' do
      expect(page).to have_content('2022-07-29')
    end

    within 'div.wice-grid-container table.wice-grid thead' do
      click_on 'ID'
    end

    within 'div.wice-grid-container table.wice-grid tbody tr:first-child td.active-filter' do
      expect(page).to have_content('2022-10-02')
    end

    within '.pagination_status' do
      expect(page).to have_content('1-20 / 35')
    end

    within 'ul.pagination' do
      click_link '2'
    end

    within 'div.wice-grid-container table.wice-grid tbody tr:first-child td.active-filter' do
      expect(page).to have_content('2022-07-02')
    end

    set_datepicker(self, 'grid_f_due_date_fr_date_placeholder', 2022, 6, 28)

    set_datepicker(self, 'grid_f_due_date_to_date_placeholder', 2022, 6, 31)

    find(:css, '#grid_submit_grid_icon').click

    within '.pagination_status' do
      expect(page).to have_content('1-1 / 1')
    end

    find(:css, '#grid_f_due_date_fr_date_view').click

    find(:css, '#grid_submit_grid_icon').click

    within '.pagination_status' do
      expect(page).to have_content('1-10 / 10')
    end

    find(:css, '#grid_f_due_date_to_date_view').click

    find(:css, '#grid_submit_grid_icon').click

    within '.pagination_status' do
      expect(page).to have_content('1-20 / 50')
    end
  end
end

shared_examples 'Added datepicker filtering' do
  it 'should filter by Added' do
    set_datepicker(self, 'grid_f_created_at_fr_date_placeholder', 2021, 5, 1)

    set_datepicker(self, 'grid_f_created_at_to_date_placeholder', 2021, 9, 1)

    find(:css, '#grid_submit_grid_icon').click

    within '.pagination_status' do
      expect(page).to have_content('1-20 / 29')
    end

    within 'div.wice-grid-container table.wice-grid tbody tr:first-child td.active-filter' do
      expect(page).to have_content('2021-09-13 22:11:12')
    end

    within 'div.wice-grid-container table.wice-grid thead' do
      click_on 'ID'
    end

    within 'div.wice-grid-container table.wice-grid tbody tr:first-child td.active-filter' do
      expect(page).to have_content('2021-09-29 22:11:12')
    end

    within '.pagination_status' do
      expect(page).to have_content('1-20 / 29')
    end

    within 'ul.pagination' do
      click_link '2'
    end

    within 'div.wice-grid-container table.wice-grid tbody tr:first-child td.active-filter' do
      expect(page).to have_content('2021-09-22 22:11:12')
    end

    find(:css, '#grid_reset_grid_icon').click

    within '.pagination_status' do
      expect(page).to have_content('1-20 / 50')
    end
  end
end

# !!!
shared_examples 'Due Date standard filtering' do
  it 'should filter by Due Date (standard filter)' do
    select '2021', from: 'grid_f_created_at_fr_year'
    select 'February', from: 'grid_f_created_at_fr_month'
    select '8', from: 'grid_f_created_at_fr_day'
    select '00', from: 'grid_f_created_at_fr_hour'
    select '00', from: 'grid_f_created_at_fr_minute'

    select '2021', from: 'grid_f_created_at_to_year'
    select 'September', from: 'grid_f_created_at_to_month'
    select '10', from: 'grid_f_created_at_to_day'
    select '00', from: 'grid_f_created_at_to_hour'
    select '00', from: 'grid_f_created_at_to_minute'

    find(:css, '#grid_submit_grid_icon').click

    within '.pagination_status' do
      expect(page).to have_content('1-16 / 16')
    end

    within 'div.wice-grid-container table.wice-grid tbody tr:first-child td.active-filter' do
      expect(page).to have_content('13 Aug 22:11')
    end

    within 'div.wice-grid-container table.wice-grid thead' do
      click_on 'ID'
    end

    within '.pagination_status' do
      expect(page).to have_content('1-16 / 16')
    end

    find(:css, '#grid_reset_grid_icon').click
    within '.pagination_status' do
      expect(page).to have_content('1-20 / 50')
    end
  end
end

shared_examples 'Created At standard filtering' do
  it 'should filter by created_at' do
    select '2021', from: 'grid_f_updated_at_fr_year'
    select 'January', from: 'grid_f_updated_at_fr_month'
    select '8', from: 'grid_f_updated_at_fr_day'
    select '00', from: 'grid_f_updated_at_fr_hour'
    select '00', from: 'grid_f_updated_at_fr_minute'

    select '2021', from: 'grid_f_updated_at_to_year'
    select 'December', from: 'grid_f_updated_at_to_month'
    select '10', from: 'grid_f_updated_at_to_day'
    select '00', from: 'grid_f_updated_at_to_hour'
    select '00', from: 'grid_f_updated_at_to_minute'

    find(:css, '#grid_submit_grid_icon').click

    within '.pagination_status' do
      expect(page).to have_content('1-14 / 14')
    end

    within 'div.wice-grid-container table.wice-grid tbody tr:first-child td.active-filter' do
      expect(page).to have_content('2021-11-26 22:11:12')
    end

    within 'div.wice-grid-container table.wice-grid thead' do
      click_on 'ID'
    end

    within 'div.wice-grid-container table.wice-grid tbody tr:first-child td.active-filter' do
      expect(page).to have_content('2021-12-07 22:11:12')
    end

    within '.pagination_status' do
      expect(page).to have_content('1-14 / 14')
    end

    find(:css, '#grid_reset_grid_icon').click

    within '.pagination_status' do
      expect(page).to have_content('1-20 / 50')
    end
  end
end

shared_examples 'Description filtering' do
  it 'should filter by Description' do
    fill_in('grid_f_description', with: 've')

    find(:css, '#grid_submit_grid_icon').click

    within '.pagination_status' do
      expect(page).to have_content('1-12 / 12')
    end

    within 'div.wice-grid-container table.wice-grid tbody tr:first-child td.active-filter' do
      expect(page).to have_content('Velit atque sapiente aspernatur sint fuga.')
    end

    expect(page).to have_content('Vero sit voluptate sed tempora et provident sequi nihil.')

    within 'div.wice-grid-container table.wice-grid thead' do
      click_on 'Description'
    end

    within '.pagination_status' do
      expect(page).to have_content('1-12 / 12')
    end

    within 'div.wice-grid-container table.wice-grid tbody tr:first-child td.active-filter' do
      expect(page).to have_content('Ad sunt vel maxime labore temporibus incidunt quidem.')
    end

    expect(page).to have_content('Adipisci voluptate sed esse velit.')

    within 'div.wice-grid-container table.wice-grid thead' do
      click_on 'ID'
    end

    within '.pagination_status' do
      expect(page).to have_content('1-12 / 12')
    end

    expect(page).to have_content('Adipisci voluptate sed esse velit.')
    expect(page).to have_content('Ad sunt vel maxime labore temporibus incidunt quidem.')

    find(:css, '#grid_reset_grid_icon').click
    within '.pagination_status' do
      expect(page).to have_content('1-20 / 50')
    end
  end
end

shared_examples 'ID filtering' do
  it 'should filter by ID, one limit' do
    fill_in('grid_f_id_eq', with: 550)

    find(:css, '#grid_submit_grid_icon').click

    within '.pagination_status' do
      expect(page).to have_content('1-1 / 1')
    end

    within 'div.wice-grid-container table.wice-grid tbody tr:first-child td.active-filter' do
      expect(page).to have_content('550')
    end
  end
end

shared_examples 'ID filtering, range' do
  it 'should filter by ID, one limit' do
    fill_in('grid_f_id_fr', with: 550)

    find(:css, '#grid_submit_grid_icon').click

    within '.pagination_status' do
      expect(page).to have_content('1-7 / 7')
    end

    within 'div.wice-grid-container table.wice-grid tbody tr:first-child td.active-filter' do
      expect(page).to have_content('550')
    end

    551.upto(556) do |i|
      expect(page).to have_content(i)
    end

    within 'div.wice-grid-container table.wice-grid thead' do
      click_on 'ID'
    end

    within '.pagination_status' do
      expect(page).to have_content('1-7 / 7')
    end

    within 'div.wice-grid-container table.wice-grid tbody tr:first-child td.sorted.active-filter' do
      expect(page).to have_content('550')
    end

    551.upto(556) do |i|
      expect(page).to have_content(i)
    end

    within 'div.wice-grid-container table.wice-grid thead' do
      click_on 'ID'
    end

    within '.pagination_status' do
      expect(page).to have_content('1-7 / 7')
    end

    within 'div.wice-grid-container table.wice-grid tbody tr:first-child td.sorted' do
      expect(page).to have_content('556')
    end

    within 'div.wice-grid-container table.wice-grid thead' do
      click_on 'Title'
    end

    within '.pagination_status' do
      expect(page).to have_content('1-7 / 7')
    end

    550.upto(556) do |i|
      expect(page).to have_content(i)
    end

    find(:css, '#grid_reset_grid_icon').click
    within '.pagination_status' do
      expect(page).to have_content('1-20 / 50')
    end
  end
end

shared_examples 'ID two limits filtering' do
  it 'should filter by ID, two limits' do
    fill_in('grid_f_id_fr', with: 507)
    fill_in('grid_f_id_to', with: 509)

    find(:css, '#grid_submit_grid_icon').click

    within '.pagination_status' do
      expect(page).to have_content('1-3 / 3')
    end

    within 'div.wice-grid-container table.wice-grid tbody tr:first-child td.active-filter' do
      expect(page).to have_content('507')
    end

    expect(page).to have_content('508')
    expect(page).to have_content('509')

    within 'div.wice-grid-container table.wice-grid thead' do
      click_on 'ID'
    end

    within '.pagination_status' do
      expect(page).to have_content('1-3 / 3')
    end

    within 'div.wice-grid-container table.wice-grid tbody tr:first-child td.sorted.active-filter' do
      expect(page).to have_content('507')
    end

    expect(page).to have_content('508')
    expect(page).to have_content('509')

    within 'div.wice-grid-container table.wice-grid thead' do
      click_on 'ID'
    end

    within '.pagination_status' do
      expect(page).to have_content('1-3 / 3')
    end

    within 'div.wice-grid-container table.wice-grid tbody tr:first-child td.sorted' do
      expect(page).to have_content('509')
    end

    within 'div.wice-grid-container table.wice-grid thead' do
      click_on 'Title'
    end

    within '.pagination_status' do
      expect(page).to have_content('1-3 / 3')
    end

    expect(page).to have_content('507')
    expect(page).to have_content('508')
    expect(page).to have_content('509')

    find(:css, '#grid_reset_grid_icon').click
    within '.pagination_status' do
      expect(page).to have_content('1-20 / 50')
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
      expect(page).to have_content('1-11 / 11')
    end

    expect(page).to have_content('Inventore iure eos labore ipsum.')
    expect(page).to have_content('Velit atque sapiente aspernatur sint fuga.')

    within 'div.wice-grid-container table.wice-grid thead' do
      click_on 'Description'
    end

    within '.pagination_status' do
      expect(page).to have_content('1-11 / 11')
    end

    expect(page).to have_content('Inventore iure eos labore ipsum.')
    expect(page).to have_content('Velit atque sapiente aspernatur sint fuga.')

    find(:css, '#grid_reset_grid_icon').click
    within '.pagination_status' do
      expect(page).to have_content('1-20 / 50')
    end
  end
end

shared_examples 'Archived filtering' do
  it 'should filter by Archived' do
    select 'yes', from: 'grid_f_archived'
    find(:css, '#grid_submit_grid_icon').click

    within '.pagination_status' do
      expect(page).to have_content('1-4 / 4')
    end

    within first(:css, 'td.active-filter') do
      expect(page).to have_content('Yes')
    end

    select 'no', from: 'grid_f_archived'
    find(:css, '#grid_submit_grid_icon').click

    within '.pagination_status' do
      expect(page).to have_content('1-20 / 46')
    end

    within first(:css, 'td.active-filter') do
      expect(page).to have_content('No')
    end

    within 'ul.pagination' do
      click_link '2'
    end

    within '.pagination_status' do
      expect(page).to have_content('21-40 / 46')
    end

    within(first(:css, 'td.active-filter')) do
      expect(page).to have_content('No')
    end

    find(:css, '#grid_reset_grid_icon').click
    within '.pagination_status' do
      expect(page).to have_content('1-20 / 50')
    end
  end
end

shared_examples 'Title filtering' do
  it 'should filter by Title' do
    fill_in('grid_f_title', with: 'ed')

    find(:css, '#grid_submit_grid_icon').click

    within '.pagination_status' do
      expect(page).to have_content('1-2 / 2')
    end

    within 'div.wice-grid-container table.wice-grid tbody tr:first-child td.active-filter' do
      expect(page).to have_content('sed impedit iste')
    end

    expect(page).to have_content('corporis expedita vel')

    within 'div.wice-grid-container table.wice-grid thead' do
      click_on 'Title'
    end

    within '.pagination_status' do
      expect(page).to have_content('1-2 / 2')
    end

    within 'div.wice-grid-container table.wice-grid tbody tr:first-child td.active-filter' do
      expect(page).to have_content('corporis expedita vel')
    end

    expect(page).to have_content('sed impedit iste')

    within 'div.wice-grid-container table.wice-grid thead' do
      click_on 'ID'
    end

    within '.pagination_status' do
      expect(page).to have_content('1-2 / 2')
    end

    expect(page).to have_content('corporis expedita vel')
    expect(page).to have_content('sed impedit iste')

    find(:css, '#grid_reset_grid_icon').click
    within '.pagination_status' do
      expect(page).to have_content('1-20 / 50')
    end
  end
end
