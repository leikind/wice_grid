# encoding: UTF-8
module Wice


  class ViewColumnBoolean < ViewColumnCustomDropdown #:nodoc:
    include ActionView::Helpers::FormOptionsHelper

    attr_accessor :boolean_filter_true_label, :boolean_filter_false_label

    def render_filter_internal(params) #:nodoc:
      @custom_filter = {
        @filter_all_label => nil,
        @boolean_filter_true_label  => 't',
        @boolean_filter_false_label => 'f'
      }

      @turn_off_select_toggling = true
      super(params)
    end
  end


end