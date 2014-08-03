# encoding: UTF-8
require 'csv'

module Wice
  class Spreadsheet  #:nodoc:

    attr_reader :tempfile

    def initialize(name, field_separator)  #:nodoc:
      @tempfile = Tempfile.new(name)
      @csv = CSV.new(@tempfile, col_sep: field_separator)
    end

    def << (row)  #:nodoc:
      @csv << row
    end

  end
end
