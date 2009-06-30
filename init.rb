require 'wice_grid.rb'
#ActionController::Base.class_eval { helper Wice::GridViewHelper }
ActionView::Base.class_eval { include Wice::GridViewHelper }
ActionController::Base.send(:include, Wice::Controller)