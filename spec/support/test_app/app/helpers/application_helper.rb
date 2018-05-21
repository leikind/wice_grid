# encoding: utf-8
module ApplicationHelper
  @@code = {}

  def show_code
    n = 0
    content_tag(:ul,
                code_chunks.map do |filename_for_view, code|
                  n += 1

                  content_tag(:li,
                              content_tag(:div,
                                          link_to(filename_for_view, "#collapse#{n}", 'data-toggle' => 'collapse', 'data-parent' => '#code-accordion', :class => 'accordion-toggle'),
                                          class: 'accordion-heading'
                              ) +
                              content_tag(:div,
                                          content_tag(:div, code, class: 'accordion-inner'),
                                          class: 'accordion-body collapse',
                                          style: 'height: 0px;',
                                          id: "collapse#{n}"
                              ),
                              class: 'list-group-item'
                  )
                end.join.html_safe,
                id: 'code-accordion',
                class: 'list-group'
    )
  end

  def code_chunks
    [].tap do |res|
      res << code_for(@controller_file, @controller_file_to_show, :ruby)

      @view_files_dir.each do|filename_for_view, filename|
        filetype = filename_for_view =~ /\.erb/ ? :rhtml : :haml
        res << code_for(filename, filename_for_view, filetype)
      end
    end
  end

  def code_for(filename, filename_for_view, filetype = :ruby)
    code = File.read(filename)
    @@code[filetype] = CodeRay.scan("\n#{code}", filetype).div unless @@code[filename]
    [filename_for_view, @@code[filetype].html_safe]
  end

  def each_example
    @example_map.each do |section|
      section[1].each do |controller, name|
        yield controller, name
      end
    end
  end

  def current_page_title
    each_example do |controller, name|
      if controller.to_s == controller_name
        return name
      end
    end
  end

  def previous_next_example_urls
    previous_example_controller = nil
    next_example_controller     = nil

    _previous_example_controller = nil
    found = false
    each_example do |controller, _name|
      if found
        return previous_example_controller, controller
      end

      if controller.to_s == controller_name
        previous_example_controller = _previous_example_controller
        found = true
      end
      _previous_example_controller = controller
    end
    [previous_example_controller, nil]
  end
end
