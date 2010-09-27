# encoding: UTF-8
require 'csv'

module Wice
  class Spreadsheet  #:nodoc:

    attr_reader :tempfile
    # CSV in 1.9.1 is a version of FasterCSV
    if RUBY_VERSION == '1.9.1' || RUBY_VERSION == '1.9.2'

      def initialize(name, field_separator)  #:nodoc:
        @tempfile = Tempfile.new(name)
        @csv = CSV.new(@tempfile, :col_sep => field_separator)
      end

      def << (row)  #:nodoc:
        @csv << row
      end
      
    else
      def initialize(name, field_separator)  #:nodoc:
        @tempfile = Tempfile.new(name)
        @field_separator = field_separator
      end

      def << (row)  #:nodoc:
        CSV::Writer.generate(@tempfile, @field_separator) do |csv|
           csv << row.map(&:to_s)
        end
      end
    end
  end
end
