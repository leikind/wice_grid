# encoding: UTF-8
module Wice
  module MemoryAdapter
    class MemoryAdapter
      def initialize( rows, columns, kaminarafy=true )
        @rows = rows
        @klass = MemoryAdapterKlass.new(columns, self)
        @columns=Set.new
        columns.each do |col|
          @columns << col.name.to_sym
        end
        @page_num=1
        @per_page=20
      end

      def klass
        @klass
      end    

      def total_count
        length
      end
      
      def length
        @rows.length
      end

      # 1-based page number
      def current_page
        @page_num
      end

      def limit_value
        @per_page
      end

      def total_pages
        total_pages=(length.to_f / @per_page).ceil
        total_pages
      end

      # 0-based index into array
      def offset_value
        @page_num = total_pages if current_page > total_pages
            
        offset_value = (current_page-1) * @per_page
        offset_value
      end

      def num_pages
        total_pages
      end

      def last_page?
        last_page = current_page==total_pages
        last_page
      end

      def includes(*opts)
        self
      end

      def joins(*opts)
        self
      end

      def order(*opts)
        self
      end

      def where(*opts)
        self
      end

      def page(num)
        @page_num=num.to_i
        @page_num =1 if @page_num < 1
        self
      end

      def per(num)
        @per_page=num.to_i
        @per_page = 1 if @per_page < 1
        self
      end      

      def each
        start_index = offset_value
        end_index = offset_value + @per_page
        slice = @rows[start_index...end_index]
        if slice
          slice.each do |row|
            yield Row.new(row, self)
          end
        end
      end

      def has_column?(col)
        @columns.include?(col)
      end
    end

    class MemoryAdapterKlass
      def initialize( columns, memory_adapter )
        @columns = columns
        @memory_adapter = memory_adapter
      end

      def columns
        @columns
      end

      def table_name
        SecureRandom.hex
      end

      def merge_conditions(*conditions)
        ""
      end

      def unscoped(&code)
        #@memory_adapter.unscope
        code.call
        self
      end

      def connection
      end
    end

    class Row
      def initialize(row, memory_adapter)
        @row=row
        @memory_adapter = memory_adapter
      end

      def method_missing(m, *args, &block)
        if @memory_adapter.has_column?(m)
          @row[m]
        else
          super
        end
      end
    end

    class Column
      def initialize(name)
        @name = name.to_s
        @model = Model.new
      end

      def name
        @name
      end
      
      def model
        @model
      end

      def model=(model)
        @model=model
      end

      def type
        :string
      end
    end
    
    class Model
    end
  end
end
