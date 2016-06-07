module Wice
  class GridOutputBuffer < String #:nodoc:

    # defines behavior for rendering nonexistent filters.
    # If return_empty_strings_for_nonexistent_filters is true, a call to render a non existent filter will raise an exception
    # If return_empty_strings_for_nonexistent_filters is false (CSV mode), no exception will be raised.
    attr_accessor :return_empty_strings_for_nonexistent_filters

    # initializes a grid output buffer
    def initialize(*attrs)
      super(*attrs)
      @filters = HashWithIndifferentAccess.new
    end

    # returns HTML code the grid
    def to_s
      super.html_safe
    end

    # stores HTML code for a detached filter
    def add_filter(detach_with_id, filter_code)
      fail WiceGridException.new("Detached ID #{detach_with_id} is already used!") if @filters.key? detach_with_id
      @filters[detach_with_id] = filter_code
    end

    # returns HTML code for a detached filter
    def filter_for(detach_with_id)
      unless @filters.key? detach_with_id
        if @return_empty_strings_for_nonexistent_filters
          return ''
        else
          fail WiceGridException.new("No filter with Detached ID '#{detach_with_id}'!")
        end
      end

      unless @filters[detach_with_id]
        fail WiceGridException.new("Filter with Detached ID '#{detach_with_id}' has already been requested once! There cannot be two instances of the same filter on one page")
      end

      res = @filters[detach_with_id]
      @filters[detach_with_id] = false
      res
    end

    # returns HTML code for a detached filter
    alias_method :[], :filter_for
  end
end
