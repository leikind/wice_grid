module Wice
  # Taken from WillPaginate::LinkRenderer, only #html_safe for compatibility with Rails 2.3.7
  class LinkRenderer < WillPaginate::LinkRenderer #:nodoc:

    def to_html #:nodoc:
      links = @options[:page_links] ? windowed_links : []

      links.unshift page_link_or_span(@collection.previous_page, 'disabled prev_page', @options[:previous_label])
      links.push    page_link_or_span(@collection.next_page,     'disabled next_page', @options[:next_label])

      html = links.join(@options[:separator])
      @options[:container] ? @template.content_tag(:div, html.html_safe_if_needed, html_attributes) : html
    end

  end
end