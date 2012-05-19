# encoding: UTF-8
module Wice

  class ViewColumn  #:nodoc:

    class << self
      def load_column_processors

        loaded_column_processors = Hash.new
        Wice::COLUMN_PROCESSOR_INDEX.each do |column_type, column_source_file|
          unless loaded_column_processors[column_source_file]
            require "view_columns/#{column_source_file}.rb"
            column_class_name = column_source_file.classify

            unless Wice.const_defined?(column_class_name.intern)
              raise "#{column_source_file}.rb is expected to define #{column_class_name}!"
            end
            column_class = eval("Wice::#{column_class_name}")

            loaded_column_processors[column_source_file] = column_class
          end

          @@handled_type[column_type] = loaded_column_processors[column_source_file]
        end
      end

      def get_column_processor(column_type)
        @@handled_type[column_type] || ViewColumn
      end
    end

    include ActionView::Helpers::FormTagHelper
    include ActionView::Helpers::TagHelper
    include ActionView::Helpers::JavaScriptHelper
    include ActionView::Helpers::AssetTagHelper

    # fields defined from the options parameter
    FIELDS = [:attribute, :name, :html, :filter, :model, :allow_multiple_selection,
              :in_html, :in_csv, :helper_style, :table_alias, :custom_order, :detach_with_id, :ordering, :auto_reload]

    attr_accessor *FIELDS

    attr_accessor :cell_rendering_block, :grid, :css_class, :table_name, :main_table, :model, :custom_filter

    attr_reader :contains_a_text_input

    def initialize(block, options, grid_obj, tname, mtable, cfilter, view)  #:nodoc:
      self.cell_rendering_block = block
      self.grid           = grid_obj
      self.table_name     = tname
      self.main_table     = mtable
      self.custom_filter  = cfilter
      @view = view

      FIELDS.each do |field|
        self.send(field.to_s + '=', options[field])
      end
    end

    cattr_accessor :handled_type
    @@handled_type = Hash.new

    def css_class #:nodoc:
      @css_class || ''
    end

    def yield_declaration_of_column_filter #:nodoc:
      nil
    end

    def detachness #:nodoc:
      (! detach_with_id.blank?).to_s
    end

    def yield_declaration #:nodoc:
      declaration = yield_declaration_of_column_filter
      if declaration
        {
          :filterName => self.name,
          :detached    => detachness,
          :declaration => declaration
        }
      end
    end


    def config  #:nodoc:
      @view.config
    end

    def controller  #:nodoc:
      @view.controller
    end


    def render_filter #:nodoc:
      params = @grid.filter_params(self)
      res = render_filter_internal(params)
      return (res.is_a?(Array)) ? res : [res, nil]
    end

    def render_filter_internal(params) #:nodoc:
      '<!-- implement me! -->'
    end

    def form_parameter_name_id_and_query(v) #:nodoc:
      query = form_parameter_template(v)
      query_without_equals_sign = query.sub(/=$/,'')
      parameter_name = CGI.unescape(query_without_equals_sign)
      dom_id = id_out_of_name(parameter_name)
      return query, query_without_equals_sign, parameter_name, dom_id.tr('.', '_')
    end

    # bad name, because for the main table the name is not really 'fully_qualified'
    def attribute_name_fully_qualified_for_all_but_main_table_columns #:nodoc:
      self.main_table ? attribute : table_alias_or_table_name + '.' + attribute
    end

    def fully_qualified_attribute_name #:nodoc:
      table_alias_or_table_name + '.' + attribute
    end


    def filter_shown? #:nodoc:
      self.attribute && self.filter
    end

    def filter_shown_in_main_table? #:nodoc:
      filter_shown? && ! self.detach_with_id
    end


    def table_alias_or_table_name  #:nodoc:
      table_alias || table_name
    end

    def capable_of_hosting_filter_related_icons?  #:nodoc:
      self.attribute.blank? && self.name.blank? && ! self.filter_shown?
    end

    def has_auto_reloading_input?  #:nodoc:
      false
    end

    def auto_reloading_input_with_negation_checkbox?  #:nodoc:
      false
    end

    def has_auto_reloading_select?  #:nodoc:
      false
    end

    def has_auto_reloading_calendar?  #:nodoc:
      false
    end

    protected

    def form_parameter_template(v) #:nodoc:
      {@grid.name => {:f => {self.attribute_name_fully_qualified_for_all_but_main_table_columns => v}}}.to_query
    end

    def form_parameter_name(v) #:nodoc:
      form_parameter_template_hash(v).to_query
    end

    def name_out_of_template(s) #:nodoc:
      CGI.unescape(s).sub(/=$/,'')
    end

    def id_out_of_name(s) #:nodoc:
      s.gsub(/[\[\]]+/,'_').sub(/_+$/, '')
    end

  end


end