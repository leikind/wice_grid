module Wice
  class WillPaginatePaginator < ::WillPaginate::ActionView::LinkRenderer
    def html_container(html)
      tag(:div,
        tag(:ul, html),
        container_attributes
      )
    end

    def page_number(page)
      if page == current_page
        tag(:li, link(page, page, :rel => rel_value(page)), :class => 'active')
      else
        tag(:li, link(page, page, :rel => rel_value(page)))
      end
    end

    def previous_or_next_page(page, text, classname)
      if page
        tag(:li, link(text, page))
      else
        tag(:li, link(text, page), :class => 'disabled')
      end
    end

    def gap
      '<li class="disabled"><a href="#">...</a></li>'
    end

  end
end